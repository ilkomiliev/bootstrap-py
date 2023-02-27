#!/usr/bin/env bash

set -eu -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
 cat <<EOF

 This is a script to create a new python project with standard layout and files.

 Usage: 

 $0 project_dir [python_executable]

 where as:
   project_dir: the path to the new project, must be empty.
     NOTE: the last part of the path will be used as project name
   python_executable: optional, path to a python exec to be used for the venv, default is the one found in the PATH

 Examples:
 1)
   $0 /tmp/myproject

   will create a new project in /tmp/myproject, using the default python executable from PATH
 2)
   $0 /tmp/myproject /python/python3.10.1/python

   will create a new project in /tmp/myproject, using the python executable from the given location
EOF
}

on_trap() {
  rc=$?
  if [[ $rc -ne 0 ]] ; then
    [[ -d "${PROJECT_DIR+x}" ]] && rm -rf "$PROJECT_DIR"
    echo "!!! ERROR: $rc !!!"
    usage
  fi
}

trap on_trap EXIT INT TERM

PROJECT_DIR="${1}"
PYTHON_EXEC_PATH="${2:-}"

if [[ -d "$PROJECT_DIR" ]] ; then
  echo -e "#########################################################################"
  echo -e "## \033[31mERROR: \033[0m                                                "
  echo -e "## the $PROJECT_DIR exists! Please delete it before running this script! "
  echo -e "## You can use the following command:                                    "
  echo -e "## rm -rf $PROJECT_DIR                                                   "
  echo -e "#########################################################################"
  exit 1
fi

info() {
  echo -e "\n ==> $1"
}

info "Creating directory structure"
mkdir -p "$PROJECT_DIR/src"
mkdir -p "$PROJECT_DIR/test"
mkdir -p "$PROJECT_DIR/doc"
info "Done."

info "Copying the project template structure"
cp -R "$ROOT_DIR"/proj/* "$PROJECT_DIR"
info "Done."

info "Make target shell scripts executable"
find "$PROJECT_DIR/scripts" -name "*.sh" -type f -exec chmod +x {} \;
info "Done."

info "Init git repository in the $PROJECT_DIR"
git init
info "Done."

info "In order to push your changes to remote repository set your git remote url:"
info "git remote add [-m <master>] origin URL"
info "More info with:"
info "git remote --help"

info "Listing the project root dir:"
ls -la "$PROJECT_DIR"
info "Done."

info "Next steps:"
info "1) Edit the $PROJECT_DIR/scripts/env_py.sh file, if necessary to customize your pypi environment."
info "2) execute $PROJECT_DIR/scripts/setup_venv.sh to create virtual environment."
info "3) Edit $PROJECT_DIR/setup.py and $PROJECT_DIR/README.md to reflect your setup."
info "4) Start hacking!"
