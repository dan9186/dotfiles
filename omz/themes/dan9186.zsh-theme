### Segment drawing

CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
    light)
      CURRENT_FG=${CURRENT_FG:-'white'}
      CURRENT_DEFAULT_FG=${CURRENT_DEFAULT_FG:-'white'}
      ;;
    *)
      CURRENT_FG=${CURRENT_FG:-'black'}
      CURRENT_DEFAULT_FG=${CURRENT_DEFAULT_FG:-'default'}
      ;;
esac

### Theme Configuration Initialization
#
# Override these settings in your ~/.zshrc

# Current working directory
: ${DAN9186_DIR_FG:=${CURRENT_FG}}
: ${DAN9186_DIR_BG:=green}

# user@host
: ${DAN9186_CONTEXT_FG:=${CURRENT_DEFAULT_FG}}
: ${DAN9186_CONTEXT_BG:=black}

# Time
: ${DAN9186_TIME_FG:=${CURRENT_FG}}
: ${DAN9186_TIME_BG:=blue}

# Git related
: ${DAN9186_GIT_FG:=${CURRENT_FG}}
: ${DAN9186_GIT_BG:=blue}

# AWS Profile
: ${DAN9186_AWS_PROD_FG:=black}
: ${DAN9186_AWS_PROD_BG:=red}
: ${DAN9186_AWS_FG:=black}
: ${DAN9186_AWS_BG:=yellow}

# Status symbols
: ${DAN9186_STATUS_RETVAL_FG:=red}
: ${DAN9186_STATUS_ROOT_FG:=yellow}
: ${DAN9186_STATUS_JOB_FG:=white}
: ${DAN9186_STATUS_FG:=black}
: ${DAN9186_STATUS_BG:=red}

## Non-Color settings - set to 'true' to enable
# Show git working dir in the style "/git/root   master  relative/dir" instead of "/git/root/relative/dir   master"
: ${DAN9186_GIT_INLINE:=false}
# Show the git branch status in the prompt rather than the generic branch symbol
: ${DAN9186_GIT_BRANCH_STATUS:=true}


# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  SEGMENT_SEPARATOR=$'\ue0b0'
  RSEGMENT_SEPARATOR=$'\ue0b2'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

git_toplevel() {
	local repo_root=$(git rev-parse --show-toplevel)
	if [[ $repo_root = '' ]]; then
		# We are in a bare repo. Use git dir as root
		repo_root=$(git rev-parse --git-dir)
		if [[ $repo_root = '.' ]]; then
			repo_root=$PWD
		fi
	fi
	echo -n $repo_root
}


### Prompt components

prompt_git_relative() {
  local repo_root=$(git_toplevel)
  local path_in_repo=$(pwd | sed "s/^$(echo "$repo_root" | sed 's:/:\\/:g;s/\$/\\$/g')//;s:^/::;s:/$::;")
  if [[ $path_in_repo != '' ]]; then
    prompt_segment "$DAN9186_DIR_BG" "$DAN9186_DIR_FG" "$path_in_repo"
  fi;
}

# Git status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi

  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }

  local ref mode repo_status stash action

  if [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
	  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
		  ref="◈ $(command git describe --exact-match --tags HEAD 2> /dev/null)" || \
		  ref="➦ $(command git rev-parse --short HEAD 2> /dev/null)"

	  prompt_segment "$DAN9186_GIT_BG" "$DAN9186_GIT_FG"

	  if [[ $DAN9186_GIT_BRANCH_STATUS == 'true' ]]; then
		  local init ahead behind
		  init=$(command git log -n 1 2>/dev/null)
		  ahead=$(command git log --oneline @{upstream}.. 2>/dev/null)
		  behind=$(command git log --oneline ..@{upstream} 2>/dev/null)
		  if [[ -z "$init" ]]; then
		  	  PL_BRANCH_CHAR=$'\uf005'
		  elif [[ -n "$ahead" ]] && [[ -n "$behind" ]]; then
			  PL_BRANCH_CHAR=$'\u21c5'
		  elif [[ -n "$ahead" ]]; then
			  PL_BRANCH_CHAR=$'\u21b1'
		  elif [[ -n "$behind" ]]; then
			  PL_BRANCH_CHAR=$'\u21b0'
		  fi
	  fi

	  repo_status="${$(command git status --porcelain 2>/dev/null | awk '{print $1}' | sort | uniq -c | awk '{printf " "$2":"$1}')%%,}"

	  stash="$(command git stash list 2>/dev/null | wc -l | tr -d ' ')"
	  if [[ $stash -gt 0 ]]; then
		  repo_status+=" S:$stash"
	  fi

	  echo -n "${${ref:gs/%/%%}/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${repo_status}${mode}"
  fi
}

# Status
prompt_status() {
	local -a symbols

	[[ $RETVAL -ne 0 ]] && symbols+="$RETVAL"
	[[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{$DAN9186_STATUS_JOB_FG}%}⚙"

	[[ -n "$symbols" ]] && prompt_segment "$DAN9186_STATUS_BG" "$DAN9186_STATUS_FG" "$symbols"
}

#AWS Profile
prompt_aws() {
	[[ -z "$AWS_PROFILE" || "$SHOW_AWS" = false ]] && return

	prompt_segment "$DAN9186_AWS_BG" "$DAN9186_AWS_FG" "${AWS_PROFILE:gs/%/%%}"

	case "$AWS_PROFILE" in
		*prod*) prompt_segment "$DAN9186_AWS_PROD_BG" "$DAN9186_AWS_PROD_FG"  "" ;;
	esac
}

# Current working directory
prompt_dir() {
	if [[ $DAN9186_GIT_INLINE == 'true' ]] && $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
		# Git repo and inline path enabled, hence only show the git root
		prompt_segment "$DAN9186_DIR_BG" "$DAN9186_DIR_FG" "$(git_toplevel | sed "s:^$HOME:~:")"
	else
		prompt_segment "$DAN9186_DIR_BG" "$DAN9186_DIR_FG" '%~'
	fi
}

## Main prompt
build_prompt() {
	RETVAL=$?
	prompt_status
	prompt_aws
	prompt_dir
	prompt_git
	prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
