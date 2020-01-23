#!/usr/bin/env bash

function main() {
  function setup_aliases() {
    alias gst="git status"
    alias vim="nvim"
    alias vi="nvim"
    alias ll="ls -al"
  }

  function setup_environment() {
    export CLICOLOR=1
    export LSCOLORS exfxcxdxbxegedabagacad

    export LC_ALL=en_US.UTF-8

    # go environment
    export GOPATH="${HOME}/go"

    # setup path
    export PATH="${GOPATH}/bin:${PATH}"

    export EDITOR="nvim"

    export LPASS_AGENT_TIMEOUT=0

    function _gitstatus() {
      local branch
      branch="$(git branch 2>/dev/null | grep '^\*' | colrm 1 2)"

      if [[ "${branch}" != "" ]]; then
        printf "[%s]" "${branch}"
      fi
    }

    function _prompt() {
      local reset lightblue lightgreen lightred
      reset="\e[0m"
      lightblue="\e[94m"
      lightgreen="\e[92m"
      lightred="\e[91m"

      PS1="${lightblue}\\d${reset} \\t ${reset}${lightgreen}\\w${reset}${status} \$(_gitstatus) \n ‣ "
    }

    if [[ "${PROMPT_COMMAND}" != *"_prompt"* ]]; then
      PROMPT_COMMAND="_prompt;$PROMPT_COMMAND"
    fi
  }

  function setup_colors() {
    local colorscheme
    colorscheme="${HOME}/.config/colorschemes/scripts/base16-tomorrow-night.sh"

    # shellcheck source=/Users/genevieve/.config/colorschemes/scripts/base16-tomorrow-night.sh
    [[ -s "${colorscheme}" ]] && source "${colorscheme}"
  }

  function setup_completions() {
    [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
  }

  function setup_z() {
    source "/usr/local/etc/profile.d/z.sh"
  }

  local dependencies
    dependencies=(
        aliases
        environment
        colors
        completions
        z
      )

  for dependency in "${dependencies[@]}"; do
    eval "setup_${dependency}"
    unset -f "setup_${dependency}"
  done
}

function reload() {
  # shellcheck source=/Users/genevieve/.bash_profile
  source "${HOME}/.bash_profile"
}

function reinstall() {
  local workspace
  workspace="${HOME}/workspace/workspace"

  if [[ ! -d "${workspace}" ]]; then
    git clone git@github.com:genevieve/workspace "${workspace}"
  fi

  pushd "${workspace}" > /dev/null || return
    if git diff --exit-code > /dev/null ; then
      git pull -r
      bash -c "./install.sh"
    else
      echo "Cannot reinstall. There are unstaged changes."
      git diff
    fi
  popd > /dev/null || return
}

main
unset -f main
