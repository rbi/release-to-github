#!/bin/sh
docker build -t rbi/release-to-github .
docker run -e GITHUB_SHA=x -e GITHUB_TOKEN=z -v `pwd`:/github/workdir -w /github/workdir --rm rbi/release-to-github -t vTest -m "automatic release"
