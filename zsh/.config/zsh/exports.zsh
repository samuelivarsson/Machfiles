#!/bin/sh
# HISTFILE="$XDG_DATA_HOME"/zsh/history
HISTSIZE=1000000
SAVEHIST=1000000
export EDITOR="nvim"
export TERMINAL="kitty"
export BROWSER="google-chrome"
export PATH="$HOME/.local/bin":$PATH
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export PATH=$HOME/.cargo/bin:$PATH
# export PATH=$HOME/.local/share/go/bin:$PATH
export PATH=$PATH:/usr/local/go/bin
# export GOPATH=$HOME/.local/share/go
# export PATH=$HOME/.fnm:$PATH
export XDG_CURRENT_DESKTOP="Wayland"
#export PATH="$PATH:./node_modules/.bin"
# eval "$(fnm env)"
# eval "$(zoxide init zsh)"
# eval "`pip completion --zsh`"

case "$(uname -s)" in

Darwin)
	# echo 'Mac OS X'
	export SKOLA="$HOME/Min enhet/Skola"
	;;

Linux) ;;

CYGWIN* | MINGW32* | MSYS* | MINGW*)
	# echo 'MS Windows'
	;;
*)
	# echo 'Other OS'
	;;
esac
