# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts
CURRENT_BG='NONE'
CURRENT_FG=015

# Special Powerline characters
() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-16"
  SEGMENT_SEPARATOR_RIGHT=$'\ue0c6'
  SEGMENT_SEPARATOR_LEFT=$'\ue0c7'
  USER_ICON=$'\Uf0004'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR_RIGHT%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

prompt_segment_left() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  echo -n "%{%F{$1}%}$SEGMENT_SEPARATOR_LEFT%{$bg$fg%}"
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    () {
      local LC_ALL="" LC_CTYPE="en_US.UTF-16"
      ARROW_ICON=$'\Uf0734' #\ue0b1
    }
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR_RIGHT \n %{%F{white}%}$ARROW_ICON"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment 092 default $USER_ICON"%(!.%{%F{yellow}%}.) %n@%m"
  fi
}

# Dir: current working directory
prompt_dir() {
  local FOLDER_ICON
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-16"
    FOLDER_ICON=$'\ue5ff'
  }
  if [[ "$PWD" == "$HOME" ]]; then
      FOLDER_ICON=$'\Uf10b5'
  fi
  prompt_segment 062 $CURRENT_FG $FOLDER_ICON' %~'
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  if [[ -n "$VIRTUAL_ENV" && -n "$VIRTUAL_ENV_DISABLE_PROMPT" ]]; then
    prompt_segment blue black "(${VIRTUAL_ENV:t:gs/%/%%})"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local -a symbols

  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-16"
    PL_BRANCH_CHAR=$'\Uf062c'         # 
  }
  local ref dirty mode repo_path

   if [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(command git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref="◈ $(command git describe --exact-match --tags HEAD 2> /dev/null)" || \
    ref="➦ $(command git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment 214 $CURRENT_FG
    else
      prompt_segment 031 $CURRENT_FG
    fi

    local ahead behind
    ahead=$(command git log --oneline @{upstream}.. 2>/dev/null)
    behind=$(command git log --oneline ..@{upstream} 2>/dev/null)
    if [[ -n "$ahead" ]] && [[ -n "$behind" ]]; then
      PL_BRANCH_CHAR=$'\u21c5'
    elif [[ -n "$ahead" ]]; then
      PL_BRANCH_CHAR=$'\u21b1'
    elif [[ -n "$behind" ]]; then
      PL_BRANCH_CHAR=$'\u21b0'
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '±'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${${ref:gs/%/%%}/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}

# Clock: current time in HH:MM:SS format
prompt_clock() {
  local CLOCK_ICON
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-16"
    CLOCK_ICON=$'\U23F0'
  }
  
  prompt_segment_left 162 $CURRENT_FG $CLOCK_ICON' %*'
}

# Battery: current battery percentage
prompt_battery() {
  local BATTERY_ICON
  local BATTERY_PERCENTAGE
  local BATTERY_COLOR
  local BATTER_STATE

  # Get battery percentage (assuming a Linux system with upower)
  BATTERY_PERCENTAGE=$(upower -i $(upower -e | grep BAT) | grep percentage | awk '{print $2}')
  BATTERY_STATE=$(upower -i $(upower -e | grep BAT) | grep state | awk '{print $2}')

  # Choose an icon and color based on the battery percentage
  if [[ $BATTERY_STATE == "charging" ]]; then
    BATTERY_ICON=$'\Uf0084'  # Charging battery icon
    BATTERY_COLOR=023  # Blue color for charging
  elif [[ ${BATTERY_PERCENTAGE%?} -ge 80 ]]; then
    BATTERY_ICON=$'\Uf0081'  # Full battery icon
    BATTERY_COLOR=034  # Green color
  elif [[ ${BATTERY_PERCENTAGE%?} -ge 60 ]]; then
    BATTERY_ICON=$'\Uf007f'  # Medium battery icon
    BATTERY_COLOR=148  # Light green color
  elif [[ ${BATTERY_PERCENTAGE%?} -ge 40 ]]; then
    BATTERY_ICON=$'\Uf007d'  # Medium battery icon
    BATTERY_COLOR=217  # Yellow color
  elif [[ ${BATTERY_PERCENTAGE%?} -ge 20 ]]; then
    BATTERY_ICON=$'\Uf007b'  # Low battery icon
    BATTERY_COLOR=205  # Orange color
  else
    BATTERY_ICON=$'\Uf0083'  # Low battery icon
    BATTERY_COLOR=196  # Red color for low battery
  fi

  prompt_segment_left $BATTERY_COLOR $CURRENT_FG ' '$BATTERY_ICON' '$BATTERY_PERCENTAGE' '
}

# Set up real-time clock update
TRAPALRM() {
  zle reset-prompt
}
TMOUT=1

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}
PROMPT='%{%f%b%k%}$(build_prompt) '

# Right prompt (RPROMPT)
build_rprompt() {
  prompt_clock
  prompt_battery
}
RPROMPT='%{%f%b%k%}$(build_rprompt) '
