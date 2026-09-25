#!/bin/sh
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

# history
HISTFILE=~/.zsh_history

# source
plug "$HOME/.config/zsh/aliases.zsh"
plug "$HOME/.config/zsh/exports.zsh"

# plugins
# plug "esc/conda-zsh-completion"
plug "zsh-users/zsh-autosuggestions"
plug "hlissner/zsh-autopair"
plug "zap-zsh/supercharge"
plug "zap-zsh/vim"
plug "zap-zsh/zap-prompt"
plug "zap-zsh/fzf"
# plug "zap-zsh/exa"
plug "zsh-users/zsh-syntax-highlighting"

# Load and initialise completion system
autoload -Uz compinit
compinit

# keybinds
bindkey '^L' autosuggest-accept

# Gung
export SPRING_PROFILES_ACTIVE=dev

# Disabled 2026-09-25: Claude now runs in cmux (sessions survive IDE crashes and
# are restored on relaunch via claude --resume), so the tmux wrapper is no longer needed.
# # Run claude inside a per-project tmux session so sessions survive terminal/IDE
# # crashes and can be re-attached from anywhere. Opt out with: command claude
# claude() {
#   # A tmux server born in an IntelliJ terminal freezes TERMINAL_EMULATOR=
#   # JetBrains-JediTerm (and __CFBundleIdentifier) into its global env, and every
#   # session inherits it -> /terminal-setup thinks we're in IntelliJ even from kitty.
#   # Scrub both: locally (for the in-tmux branch below) and from the server global
#   # env (so future new-sessions start clean).
#   unset TERMINAL_EMULATOR __CFBundleIdentifier
#   tmux setenv -gu TERMINAL_EMULATOR    2>/dev/null
#   tmux setenv -gu __CFBundleIdentifier 2>/dev/null
#   # Also drop any stale IDE port frozen into the server global env: it would force
#   # every session onto ONE IntelliJ window regardless of pwd. Removing it lets
#   # Claude auto-discover the right window by matching cwd to ~/.claude/ide/*.lock.
#   # NOTE: only scrub the *global* value, never the local one -- the block below
#   # reads $CLAUDE_CODE_SSE_PORT from the launching shell to seed a real IDE session.
#   # Leave ENABLE_IDE_INTEGRATION alone so discovery stays enabled.
#   tmux setenv -gu CLAUDE_CODE_SSE_PORT 2>/dev/null
# 
#   # Already inside tmux -> run the real binary, no nesting.
#   if [[ -n "$TMUX" ]]; then
#     command claude "$@"
#     return
#   fi
#   local proj="${PWD:t}"                             # basename of current dir
#   local sess="claude-${proj//[^A-Za-z0-9_-]/-}"     # sanitize (tmux dislikes . and :)
#   # Seed THIS terminal's IDE port into the session so claude connects to the
#   # right IntelliJ window (tmux -e overrides the server's frozen global env).
#   local -a envargs
#   [[ -n "$CLAUDE_CODE_SSE_PORT" ]]   && envargs+=(-e "CLAUDE_CODE_SSE_PORT=$CLAUDE_CODE_SSE_PORT")
#   [[ -n "$ENABLE_IDE_INTEGRATION" ]] && envargs+=(-e "ENABLE_IDE_INTEGRATION=$ENABLE_IDE_INTEGRATION")
#   if tmux has-session -t "$sess" 2>/dev/null; then
#     # refresh the port so a claude restarted inside the session gets the right window
#     [[ -n "$CLAUDE_CODE_SSE_PORT" ]] && tmux setenv -t "$sess" CLAUDE_CODE_SSE_PORT "$CLAUDE_CODE_SSE_PORT"
#     tmux attach -t "$sess"                          # exists -> reattach
#   elif (( $# )); then                               # new session, with args
#     tmux new-session "${envargs[@]}" -s "$sess" "cd ${(q)PWD} && exec command claude ${(q)*}"
#   else                                              # new session, no args
#     tmux new-session "${envargs[@]}" -s "$sess" "cd ${(q)PWD} && exec command claude"
#   fi
# }

# if
# 	command -v bat &
# 	>/dev/null
# then
# 	alias cat="bat -pp --theme \"Visual Studio Dark+\""
# 	alias catt="bat --theme \"Visual Studio Dark+\""
# fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

case "$(uname -s)" in

Darwin)
	# echo 'Mac OS X'
    export NVM_DIR=~/.nvm
    source $(brew --prefix nvm)/nvm.sh
    plug "$HOME/.config/zsh/vpn-aliases.zsh"
    plug "$HOME/.config/zsh/secret-exports.zsh"
	;;

Linux)
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
	;;

CYGWIN* | MINGW32* | MSYS* | MINGW*)
	# echo 'MS Windows'
	;;
*)
	# echo 'Other OS'
	;;
esac
fpath=(~/.zsh/completions $fpath)
autoload -U compinit && compinit
fpath=(~/.zsh/completions $fpath)
autoload -U compinit && compinit
