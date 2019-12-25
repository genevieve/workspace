#!/usr/bin/env bash

function main() {
  function setup_aliases() {
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

    function _bgjobs() {
      local count
      count="$(jobs | wc -l | tr -d ' ')"

      if [[ "${count}" == "1" ]]; then
        printf "%s" "${count} job "
      elif [[ "${count}" != "0" ]]; then
        printf "%s" "${count} jobs "
      fi
    }

    function _gitstatus() {
      local branch status
      branch="$(git branch 2>/dev/null | grep '^\*' | colrm 1 2)"

      if [[ "${branch}" != "" ]]; then
        printf "[%s] %s" "${branch}" "${status}"
      fi
    }

    function _prompt() {
      local status="${?}"

      local reset lightblue lightgreen lightred
      reset="\e[0m"
      lightblue="\e[94m"
      lightgreen="\e[92m"
      lightred="\e[91m"

      if [[ "${status}" != "0" ]]; then
        status="$(printf "%s" " ☠️  ${lightred}{${status}}${reset}")"
      else
        status=""
      fi


      PS1="${lightblue}\\d${reset} \\t ${lightred}\$(_bgjobs)${reset}${lightgreen}\\w${reset}${status} \$(_gitstatus) \n ‣ "
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

  local dependencies
    dependencies=(
        aliases
        environment
        colors
        completions
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
