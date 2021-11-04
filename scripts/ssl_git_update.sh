#!/bin/sh
#Update SSL from Git repo

cd /etc/nginx/cert
branch=$(git rev-parse --abbrev-ref HEAD)
local_commit = $(git rev-parse HEAD)
origin_commit=$(git rev-parse origin/${branch})
if [$local_commit != $origin_commit]
then    
    git pull --depth 1
    service nginx force-reload
fi