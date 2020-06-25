#!/bin/bash
set -e

home=${HOME}/.gitprofile

error () {
    echo "profile: $2"
    exit $1
}

git_profile_init () {
    [[ -d ${home} ]] || mkdir -p ${home}
    cd ${home}
}

git_profile_clone () {
    git_profile_init
    [[ -z "$1" ]] && error 1 "missing profile name"
    #[[ -z "$2" ]] && error 1 "missing git repository"
    [[ -d "$1" ]] && error 1 "profile alredy exists"
    git clone $1 $2
    [[ -d current ]] || ln -s $2 current
}

git_profile_use () {
    git_profile_init
    [[ -z "$1" ]] && error 1 "missing profile name"
    [[ -d "$1" ]] || error 1 "profile not exists"
    [[ -L current ]] && rm -fr current
    ln -s $1 current
}

git_profile_edit () {
    git_profile_init
    #[[ -z "$1" ]] && error 1 "missing profile name"
    [[ -d current ]] || error 1 "profile not exists"
    #[[ -d current ]] && rm -fr current
    cd current
    nano $1
    git add .
    git commit -am "edit"
    git push
}

git_profile_ls () {
    git_profile_init
    ls -l
}

case $1 in
    use) git_profile_use $2 ;;
    clone) git_profile_clone $2 $3 ;;
    edit) git_profile_edit $2 ;;
    ls) git_profile_ls ;;
    *) error 1 "'$1' is not a profile command. See 'git profile --help'."
esac
