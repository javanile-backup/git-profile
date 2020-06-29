#!/usr/bin/env bash

##
# git-profile
#
# Manage your profile with GIT.
#
# Copyright (c) 2020 Francesco Bianco <bianco@javanile.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##

set -e

home=${HOME}/.gitprofile
username=^[a-zA-Z0-9]+\(-[a-zA-Z0-9]+\)*$
package=^[A-Za-z_\.-]+/[A-Za-z_\.-]+$

##
#
##
usage () {
    echo "Usage: git profile [--help] <command> [<args>]"
    echo ""
    echo "Executes FILE as a test case also collect each LCOV info and generate HTML report"
    echo ""
    echo "List of available options"
    echo "  -e, --extension EXT     Coverage of every *.EXT file (default: sh)"
    echo "  -i, --include PATH      Include files matching PATH"
    echo "  -x, --exclude PATH      Exclude files matching PATH"
    echo "  -o, --output OUTDIR     Write HTML output to OUTDIR"
    echo "  -h, --help              Display this help and exit"
    echo "  -v, --version           Display current version"
    echo ""
    echo "Documentation can be found at https://github.com/javanile/lcov.sh"
}

##
#
##
error () {
    echo "profile: $2"
    exit "$1"
}

##
#
##
git_profile_init () {
    [[ -d "${home}" ]] || mkdir -p "${home}"
    cd "${home}"
}

##
#
##
git_profile_clone () {
    git_profile_init
    [[ -z "$1" ]] && error 1 "missing profile name"
    if [[ $1 =~ ${package} ]]; then
        [[ -z $2 ]] && repository="https://github.com/$1" || repository="$2/$1"
        profile=$(dirname "$1")
    elif [[ $1 =~ ${username} ]]; then
        [[ -z $2 ]] && repository="https://github.com/$1/gitprofile" || repository="$2/$1/gitprofile"
        profile=$1
    else
        error 1 "invalid profile name: $1"
    fi

    [[ -d "${profile}" ]] && error 1 "profile already exists"
    git clone "${repository}" "${profile}"
    [[ -d current ]] || ln -s "${profile}" current
}

##
#
##
git_profile_use () {
    git_profile_init
    [[ -z "$1" ]] && error 1 "missing profile name"
    [[ -d "$1" ]] || error 1 "profile not exists"
    [[ -L current ]] && rm -fr current
    ln -s "$1" current
}

##
#
##
git_profile_edit () {
    git_profile_init
    #[[ -z "$1" ]] && error 1 "missing profile name"
    [[ -d current ]] || error 1 "profile not exists"
    #[[ -d current ]] && rm -fr current
    cd current
    nano "$1"
    git add .
    git commit -am "edit"
    git push
}

##
#
##
git_profile_ls () {
    git_profile_init
    ls -l
}

##
#
##
git_profile_shell () {
    git_profile_init
    cd current
    bash
}

##
#
##
git_profile_mkdir () {
    git_profile_init
    cd current
    mkdir -p $1
}

##
#
##
git_profile_touch () {
    git_profile_init
    cd current
    touch $1
}

##
#
##
case $1 in
    use) git_profile_use "$2" ;;
    add|clone) git_profile_clone "$2" "$3" ;;
    shell) git_profile_shell "$2" "$3" ;;
    mkdir) git_profile_mkdir "$2" ;;
    touch) git_profile_touch "$2" ;;
    edit) git_profile_edit "$2" ;;
    ls) git_profile_ls ;;
    --help) usage ;;
    "") error 1 "syntax error missing command. See 'git profile --help'." ;;
    *) error 1 "'$1' is not a profile command. See 'git profile --help'." ;;
esac
