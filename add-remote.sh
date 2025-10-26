#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset

# require server name to use

usage() {
    echo must specify remote git hostname
    echo "$0 [oak|piserver]"
    exit 1
}

# Make sure we're in project root
if ! [ -d .git ]
then
    echo "You'll be sorry if you don't run this from the project root"
    exit 1
fi

if [ -z "${1+x}" ]
then
    usage
else
    case $1 in
        "piserver"|"oak")
            host=$1
            ;;
        *)
            usage
            ;;
    esac
fi

repo="$(basename "$(pwd)").git"

git remote add "$host" "ssh://git@${host}:10022/HankB/${repo}"
git remote set-url --add --push origin "ssh://git@piserver:10022/HankB/${repo}"
git remote set-url --add --push origin "ssh://git@oak:10022/HankB/${repo}"
git remote show origin
