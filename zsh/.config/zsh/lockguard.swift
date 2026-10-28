import Cocoa
import CoreGraphics
import AVFoundation

// ── Anti-prank "booby trap" ──────────────────────────────────────────────
// Any mouse movement/click/scroll, or any key that isn't the next key in the
// disarm sequence, snaps a webcam photo of the culprit, makes it the wallpaper
// (which the lock screen shows) and locks the screen. Enter the disarm sequence
// in order (nothing else in between) to disarm safely.
// After you unlock, the original wallpaper is restored; the photo is kept in
// ~/Pictures/lockguard. `lockguard --test` runs the photo/wallpaper part right
// away without locking.

let ARMING_DELAY: UInt32 = 4          // seconds to take your hands off
let DISARM_SEQUENCE: [Int64] = [4, 14, 38]   // disarm keycodes, in order
let CAPTURE_TIMEOUT: Double = 4       // lock anyway if the camera hasn't delivered by then
let PHOTO_DIR = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Pictures/lockguard")
let TEST_MODE = CommandLine.arguments.contains("--test")
var seqIndex = 0                       // progress through the disarm sequence
var tripped = false
var tapRef: CFMachPort?

func log(_ message: String) {
    FileHandle.standardError.write((message + "\n").data(using: .utf8)!)
}

func lockScreen() {
    // SACLockScreenImmediate() from login.framework locks the screen synchronously,
    // independent of the "require password" setting or any keyboard shortcut. This is
    // reliable even though we exit right after (unlike posting synthetic keystrokes,
    // which get dropped when the process dies before the events are delivered).
    if let handle = dlopen("/System/Library/PrivateFrameworks/login.framework/login", RTLD_NOW),
       let sym = dlsym(handle, "SACLockScreenImmediate") {
        typealias LockFn = @convention(c) () -> Int32
        let lock = unsafeBitCast(sym, to: LockFn.self)
        _ = lock()
    } else {
        // Fallback: sleep the display (locks if a password is required after sleep).
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["displaysleepnow"]
        try? task.run()
        task.waitUntilExit()
    }
    usleep(300_000)   // give the lock request time to reach loginwindow before we exit
}

// ── Intruder photo ───────────────────────────────────────────────────────

final class IntruderCamera: NSObject, AVCapturePhotoCaptureDelegate {
    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var completion: ((URL?) -> Void)?

    func snap(completion: @escaping (URL?) -> Void) {
        self.completion = completion
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
            ?? AVCaptureDevice.default(for: .video)
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized,
              let device, let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input), session.canAddOutput(output) else {
            return finish(nil)
        }
        session.sessionPreset = .photo
        session.addInput(input)
        session.addOutput(output)
        DispatchQueue.global().async {
            self.session.startRunning()
            // Let auto-exposure settle, otherwise the first frame is nearly black.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            }
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let data = photo.fileDataRepresentation() else { return finish(nil) }
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let url = PHOTO_DIR.appendingPathComponent("intruder-\(stamp).jpg")
        do {
            try FileManager.default.createDirectory(at: PHOTO_DIR, withIntermediateDirectories: true)
            try data.write(to: url)
            finish(url)
        } catch {
            finish(nil)
        }
    }

    private func finish(_ url: URL?) {
        DispatchQueue.global().async { self.session.stopRunning() }
        DispatchQueue.main.async {
            self.completion?(url)
            self.completion = nil
        }
    }
}

// ── Wallpaper swap ───────────────────────────────────────────────────────

typealias Wallpaper = (screen: NSScreen, url: URL, options: [NSWorkspace.DesktopImageOptionKey: Any])
var originalWallpapers: [Wallpaper] = []

func setWallpaper(_ photo: URL) {
    let workspace = NSWorkspace.shared
    let options: [NSWorkspace.DesktopImageOptionKey: Any] = [
        .imageScaling: NSImageScaling.scaleProportionallyUpOrDown.rawValue,
        .allowClipping: true,
    ]
    for screen in NSScreen.screens {
        if let url = workspace.desktopImageURL(for: screen) {
            originalWallpapers.append((screen, url, workspace.desktopImageOptions(for: screen) ?? [:]))
        }
        try? workspace.setDesktopImageURL(photo, for: screen, options: options)
    }
}

func restoreWallpapers() {
    for wallpaper in originalWallpapers {
        try? NSWorkspace.shared.setDesktopImageURL(wallpaper.url, for: wallpaper.screen, options: wallpaper.options)
    }
}

// ── Trip ─────────────────────────────────────────────────────────────────

let camera = IntruderCamera()

func trip() {
    tripped = true
    var locked = false
    let lockWithPhoto: (URL?) -> Void = { photo in
        guard !locked else { return }
        locked = true
        // Stop intercepting input so the password can be typed on the lock screen.
        if let tap = tapRef { CGEvent.tapEnable(tap: tap, enable: false) }
        if let photo {
            log("📸 \(photo.path)")
            setWallpaper(photo)
            usleep(500_000)   // let the wallpaper change land before the lock screen draws
        }
        if TEST_MODE {
            log("Test mode — not locking. Restoring wallpaper in 5 s.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                restoreWallpapers()
                exit(0)
            }
            return
        }
        lockScreen()
        if originalWallpapers.isEmpty { exit(0) }
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil, queue: .main
        ) { _ in
            restoreWallpapers()
            exit(0)
        }
    }
    camera.snap(completion: lockWithPhoto)
    DispatchQueue.main.asyncAfter(deadline: .now() + CAPTURE_TIMEOUT) { lockWithPhoto(nil) }
}

let eventMask: CGEventMask =
    (1 << CGEventType.keyDown.rawValue) |
    (1 << CGEventType.mouseMoved.rawValue) |
    (1 << CGEventType.leftMouseDown.rawValue) |
    (1 << CGEventType.rightMouseDown.rawValue) |
    (1 << CGEventType.otherMouseDown.rawValue) |
    (1 << CGEventType.scrollWheel.rawValue)

let callback: CGEventTapCallBack = { proxy, type, event, refcon in
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if !tripped, let tap = refcon?.assumingMemoryBound(to: CFMachPort.self).pointee {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return nil
    }
    if tripped { return nil }   // swallow input while the photo is being taken
    if type == .keyDown {
        let keycode = event.getIntegerValueField(.keyboardEventKeycode)
        if keycode == DISARM_SEQUENCE[seqIndex] {
            seqIndex += 1
            if seqIndex == DISARM_SEQUENCE.count {
                log("Disarmed — no lock.")
                exit(0)
            }
            return nil   // correct key so far; swallow it and wait for the rest
        }
    }
    // Any other input → photo, wallpaper, lock.
    trip()
    return nil
}

// Ask for camera access up front so a permission dialog never pops up mid-trip.
if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
    let answered = DispatchSemaphore(value: 0)
    AVCaptureDevice.requestAccess(for: .video) { _ in answered.signal() }
    answered.wait()
}
if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
    log("⚠️  No camera access — will lock without a photo. Allow your terminal under Privacy & Security → Camera.")
}

if TEST_MODE {
    trip()
    CFRunLoopRun()
}

// Countdown so your own launch keystroke / hand-off doesn't trip it.
for i in stride(from: Int(ARMING_DELAY), through: 1, by: -1) {
    log("Arming in \(i)... (take your hands off)")
    sleep(1)
}

guard let tap = CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: eventMask,
    callback: callback,
    userInfo: withUnsafeMutablePointer(to: &tapRef) { UnsafeMutableRawPointer($0) }
) else {
    log("ERROR: Could not create event tap.\nGrant your terminal Accessibility (and Input Monitoring) permission in System Settings → Privacy & Security, then retry.")
    exit(1)
}
tapRef = tap

let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)

log("🔒 ARMED. Any mouse movement or wrong key snaps your photo and locks the screen. Enter your disarm sequence to stop.")
CFRunLoopRun()
