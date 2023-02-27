#!/usr/bin/env bash

set -eu -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

usage() {
  cat <<EOF

  Packages and uploads to a pypi artifact repository. If custom repository is used env_py.sh can be used to define it.
  The script uses setuptools, wheel and twine. Credentials can be passed using the standard twine environment variables:
  TWINE_USERNAME and TWINE_PASSWORD

  It requires existing python virtual environment. One can be set with the provided setup_venv.sh script.

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

DIST_DIR="$ROOT_DIR/dist"
BUILD_DIR="$ROOT_DIR/build"
ENV_SH_FILE="$SCRIPTS_DIR/env_py.sh" # optional for custom TWINE_REPO_URL

activate_venv "$VENV_DIR"

source_env_sh_file "$ENV_SH_FILE"

info "Cleaning up the dist and build dirs"
[[ -d "$DIST_DIR" ]] && rm -rf "$DIST_DIR"
[[ -d "$BUILD_DIR" ]] && rm -rf "$BUILD_DIR"
info "Done."

info "Cleaning up rest overs eggs"
for dir in $(find . -name "*.egg-info" -type d -print) ; do
  echo "Removing $dir"
  rm -rf "${dir}"
done
info "Done."

info "Installing setuptools, wheel, twine"
python -m pip install --upgrade setuptools wheel twine
info "Done."

info "Build package"
python setup.py sdist bdist_wheel
info "Done."

[[ -n "${TWINE_USERNAME+x}" ]] || errx "TWINE_USERNAME must be provided!"
[[ -n "${TWINE_PASSWORD+x}" ]] || errx "TWINE_PASSWORD must be provided!"

if [[ -n "${TWINE_REPO_URL+x}" ]] ; then
  info "Uploading to custom twine repository: $TWINE_REPO_URL"
  python -m twine upload --repository-url "$TWINE_REPO_URL" dist/*
else
  info "Uploading to pypi.org"
  python -m twine upload dist/*
fi
info "Done."