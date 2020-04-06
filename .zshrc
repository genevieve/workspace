export ZSH="/Users/genevieve/.oh-my-zsh"

ZSH_THEME="robbyrussell"

source "${HOME}/.config/colorschemes/scripts/base16-tomorrow-night.sh"

plugins=(
  git
  z
)

source $ZSH/oh-my-zsh.sh

export CLICOLOR=1
export LSCOLORS exfxcxdxbxegedabagacad

export LC_ALL=en_US.UTF-8

export EDITOR='nvim'

export GOPATH="${HOME}/go"
export GO111MODULE=on

export PATH="${GOPATH}/bin:${PATH}"

export LPASS_AGENT_TIMEOUT=0

alias gst="git status"
alias vim="nvim"
alias vi="nvim"
alias ll="ls -al"

function reload() {
  source "${HOME}/.zshrc"
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
      ./install.sh
    else
      echo "Cannot reinstall. There are unstaged changes."
      git diff
    fi
  popd > /dev/null || return
}
