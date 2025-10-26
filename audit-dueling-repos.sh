#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
############### end of Boilerplate

for dir in oak piserver both
do
    mkdir -p ${dir:?}/
    rm -rf ${dir:?}/* || true
done

for repo in $(wget -q -O - "http://oak:8080/api/v1/users/HankB/repos?limit=50"|jq ' .[] | .name' | sed s/\"//g)
do
    echo "auditing $repo"
    cd oak
    git clone -q "ssh://git@oak:10022/HankB/$repo.git" || echo missing repo
    rm -rf "$repo/.git"

    cd ../piserver
    git clone -q "ssh://git@piserver:10022/HankB/$repo.git" || echo missing repo
    rm -rf "$repo/.git"

    cd ..
    diff -rq "oak/$repo" "piserver/$repo" || echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<FOUND ONE" 

    cd both
    git clone -q "ssh://git@oak:10022/HankB/$repo.git" || echo missing repo
    cd "$repo"
    git remote add piserver "ssh://git@piserver:10022/HankB/${repo}"
    branch=$(/bin/git branch | awk '{print $2}')
    git pull -q piserver "$branch" || echo missing repo
    cd ../..
done
