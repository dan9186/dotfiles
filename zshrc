# This is the base of the new zsh directory
MYZSH="$HOME/.myzsh"

# Specify a tmp directory to use across all modules
TMPDIR="/tmp"

# This is the theme.
THEME="default"

# This is the list of modules that generate Left Primary output.
LPRIMARY=(pwd git jobs vim)

# This is the list of modules that generate Left Secondary output.
LSECONDARY=(exitcode userhost gettime)

# This is the list of modules that generate Right Primary output.
RPRIMARY=(ipaddr)

# This is the list of modules that generate Right Secondary output.
if [ "$DOCKER" = "true" ]; then
	RSECONDARY=(getdate)
else
	RSECONDARY=(getdate battery)
fi

# This is the title of the terminal
TITLE=(pwd)

# This is the list of modules that get processed once at shell start.
# They shouldn't generate output.
if [ "$DOCKER" = "true" ]; then
	EXTRA=(ssh-add localbin completions lesscolors lscolors ll coloncolon longcmd safe-paste grepcolors golang timer history releases)
else
	EXTRA=(ssh-add localbin completions lesscolors lscolors ll coloncolon longcmd safe-paste grepcolors tmux alwaystmux golang timer docker history releases)
fi

if [ "$DOCKER" = "true" ]; then
	PR_PRIMARY='$PR_BLUE'
else
	PR_PRIMARY='$PR_GREEN'
fi

################################################################################
# This kicks off our processing now that we have variables
BATT_METER="0"
BATT_PCT="1"
BATT_TIME="1"
GIT_USE_ICONS="1"
source "$MYZSH/init"
