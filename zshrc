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
RSECONDARY=(getdate battery)

# This is the title of the terminal
TITLE=(pwd)

# This is the list of modules that get processed once at shell start.
# They shouldn't generate output.
EXTRA=(ssh-add localbin completions lesscolors lscolors ll coloncolon longcmd safe-paste grepcolors tmux alwaystmux golang timer docker history releases)

PR_PRIMARY='$PR_GREEN'

################################################################################
# This kicks off our processing now that we have variables
BATT_METER="1"
BATT_PCT="1"
BATT_TIME="1"
GIT_USE_ICONS="1"
source "$MYZSH/init"
