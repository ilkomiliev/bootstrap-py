#!/usr/bin/env bash

set -eu -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

usage() {
  cat <<EOF

  Install the requirements and executes formatting, linting, ... and pytest at the end. Configuration can be done in
  pyproject.toml

  Usage:
  1)
    $0

EOF
}

on_trap() {
  rc=$?
  if [[ $rc -ne 0 ]] ; then
    info "!!! ERROR: $rc !!!"
    usage
  fi
}

trap on_trap EXIT INT TERM

SCRIPTS_DIR="$ROOT_DIR"/scripts
VENV_DIR="$ROOT_DIR/venv" # the root of the venv

source "$SCRIPTS_DIR"/utils.sh

activate_venv "$VENV_DIR"

info "Updating pip"
pip install --upgrade pip
info "Done."

info "Installing requirements from:"
for f in $(find . -name "requirements*.txt") ; do
  echo "$f"
  pip install -r "$f"
done
info "Done."

info "Running flake8"
flake8 ./src --count --select=E9,F63,F7,F82 --show-source --statistics
flake8 ./src --count --exit-zero --max-complexity=10 --max-line-length=125 --statistics
info "Done."

info "Running pylint"
pylint ./src || echo "ERRORS FOUND!!!"
info "Done."

info "Running pytest"
pytest
info "Done."