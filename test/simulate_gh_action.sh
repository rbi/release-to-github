#!/bin/sh

GITHUB_TOKEN="<censored>"

docker build -t rbi/release-to-github .
docker run -e GITHUB_TOKEN=${GITHUB_TOKEN} -v `pwd`:/github/workdir -w /github/workdir --rm rbi/release-to-github -t vTest -p -m "automatic release" -f entrypoint.sh,Dockerfile
