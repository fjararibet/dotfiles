prompt off
setopt prompt_subst

autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*:*' unstagedstr '!'
zstyle ':vcs_info:*:*' stagedstr '+'
zstyle ':vcs_info:*:*' formats "%%B%r%%b/%S" " %b" "%%u%c"
zstyle ':vcs_info:*:*' actionformats "%%B%r%%b/%S" " %b" "%u%c (%a)"
zstyle ':vcs_info:*:*' nvcsformats "%~" "" ""

git_dirty() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  command git diff --quiet --ignore-submodules HEAD &>/dev/null
  [ $? -eq 1 ] && echo "*"
}

repo_information() {
  echo "%F{magenta}${vcs_info_msg_0_%%/.}%F{8}$vcs_info_msg_1_`git_dirty` $vcs_info_msg_2_%f"
}

# Git work runs in a process-substitution worker. ZLE watches its pipe and
# redraws the prompt once the complete, NUL-terminated result is available.
typeset -g prompt_repo_information='%F{magenta}%~%f'
typeset -g prompt_repo_directory
typeset -g prompt_git_fd

prompt_git_ready() {
  local fd=$1 result
  if [[ -z $2 ]] && IFS= read -r -d '' -u "$fd" result; then
    prompt_repo_information=$result
  fi
  zle -F "$fd"
  exec {fd}<&-
  unset prompt_git_fd
  zle reset-prompt
}

prompt_git_update() {
  # Discard the previous pipe so a result from an old prompt cannot win a race.
  if [[ -n $prompt_git_fd ]]; then
    zle -F "$prompt_git_fd"
    exec {prompt_git_fd}<&-
    unset prompt_git_fd
  fi
  if [[ $prompt_repo_directory != $PWD ]]; then
    prompt_repo_information='%F{magenta}%~%f'
    prompt_repo_directory=$PWD
  fi
  exec {prompt_git_fd}< <(
    vcs_info
    print -rn -- "$(repo_information)"$'\0'
  )
  zle -F "$prompt_git_fd" prompt_git_ready
}

cmd_exec_time() {
  local stop=`date +%s`
  local start=${cmd_timestamp:-$stop}
  let local elapsed=$stop-$start
  [ $elapsed -gt 5 ] && echo ${elapsed}s
}

preexec() {
  [ -n "$TMUX" ] && tmux rename-window "${1%% *}"
  cmd_timestamp=`date +%s`
}

precmd() {
  prompt_exec_time=$(cmd_exec_time)
  prompt_git_update
  unset cmd_timestamp
}

PROMPT=$'\n%F{8}%n@%m:%f${prompt_repo_information} %F{yellow}${prompt_exec_time}%f\n%(?.%F{cyan}.%F{red})$%f '
RPROMPT=""
