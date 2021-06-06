#!/bin/sh

set -e

docker run --rm -it --env-file env.txt -v ${PWD}/course:/course michaelkubecourse/tools
