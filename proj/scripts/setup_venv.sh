#!/usr/bin/env bash

set -eu -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

usage() {
  cat <<EOF

  This script (re-)creates new python virtual environment. If an existing one is found it will be deleted and re-created.
  The environment will be created in the venv sub-folder. For customizing the environment, env_py.sh can be used.

  Usage:

  $0 [python_executable]

  where as:
    python_executable: optional, path to a python exec to be used for the venv, default is the one found in the PATH

  Examples:
  1)
    $0

    will create a new virtual environment, using the default python executable from PATH
  2)
    $0 /python/python3.10.1/python

    will create a new virtual environment, using the python executable from the given location

EOF
}

on_trap() {
  rc=$?
  if [[ $rc -ne 0 ]] ; then
    echo "!!! ERROR: $rc !!!"
    usage
  fi
}

trap on_trap EXIT INT TERM

SCRIPTS_DIR="$ROOT_DIR/scripts" # my dir
VENV_DIR="$ROOT_DIR/venv" # the root of the venv
ENV_SH_FILE="$SCRIPTS_DIR/env_py.sh" # optional env settings for the venv like PIP_INDEX_URL

source "$SCRIPTS_DIR"/utils.sh

PY_EXEC="${1:- }" # optional, if the correct python executable is not in the PATH

if [[ "${PY_EXEC}" == " " ]] ; then
  PY_EXEC="$(which python || which python3)"
fi

info "Using python from: $PY_EXEC"

PY_VERSION="$($PY_EXEC --version |awk '{print $2}')"

info "python version: $PY_VERSION"

if [[ -d "${VENV_DIR}" ]]; then
  info "Existing venv found - deleting it"
  rm -rf "${VENV_DIR}"
fi

source_env_sh_file "$ENV_SH_FILE"

info "Creating venv"
"$PY_EXEC" -m venv "${VENV_DIR}"
info "Done."

activate_venv "$VENV_DIR"

info "Adapting pip.ini from $ENV_SH_FILE"
[[ -n "${PIP_INDEX_URL+x}" ]] && pip config --site set global.index-url "$PIP_INDEX_URL"
[[ -n "${PIP_SEARCH_URL+x}" ]] && pip config --site set global.index "$PIP_SEARCH_URL"
[[ -n "${PIP_TRUSTED_HOST+x}" ]] && pip config --site set global.trusted-host "$PIP_TRUSTED_HOST"
[[ -n "${PIP_CERT+x}" ]] && pip config --site set global.cert "$PIP_CERT"
info "Done."

info "Upgrade pip to the latest version"
python -m pip install --upgrade pip
info "Done."

info "Using venv python from: $(which python)"
info "Version: $(python --version)"
info "pip config: $(pip config --site list)"
info "Packages: $(pip list)"
