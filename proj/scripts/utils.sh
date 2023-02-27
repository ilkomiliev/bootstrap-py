#!/usr/bin/env bash

## writes an info message on new line
##
## params:
## 1: the message
info() {
  echo -e "\n ==> $1"
}

## exits on error with error message
##
#ä params:
## 1: the error message, will be prefixed with ERROR: the exit code (see below)
## 2: (optional) the exit code, default = 1
errx() {
  rc="${2:-1}"
  info "ERROR: $1"
  exit "$rc"
}

## activates python venv
##
## params:
## 1: the path to the venv
activate_venv() {
  venv_dir="$1"
  info "Activating the env"
  activate_script="$(find "$venv_dir" -name activate)" # windows has some special structure ...
  # shellcheck disable=SC1090
  source "${activate_script}"
  info "Done."
}

## sources env sh file
##
## params:
## 1: the path to the env file to be sourced
source_env_sh_file() {
  env_file="$1"
  if [[ -f "$env_file" ]] ; then
    info "Sourcing env file with the following custom settings:"
    cat "$env_file"
    # shellcheck disable=SC1090
    source "$env_file"
  info "Done."
fi
}