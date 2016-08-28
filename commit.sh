#!/bin/sh

git add *.md *.sh
git add LICENSE
git add $(find -P SOURCE -type f)

git commit -m "$*"
git push