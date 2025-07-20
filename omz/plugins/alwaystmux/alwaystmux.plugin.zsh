(( ${+commands[tmux]} )) || return

: ${TMUX_LOCAL_PREFIX:=z}
: ${TMUX_REMOTE_PREFIX:=a}

if [ -z "$TMUX" ]; then
	local key=$TMUX_LOCAL_PREFIX

	[ -n "$SSH_CLIENT" ] && key=$TMUX_REMOTE_PREFIX

	tmux has-session -t main || tmux new-session -d -s main
	tmux set-option -g prefix C-$key
	tmux set-option -g aggressive-resize on
	tmux bind-key C-$key last-window
	tmux bind-key $key send-prefix
	tmux new-session -t main \; set-option destroy-unattached && exit
fi
