#!/bin/sh
#
# All this is based on .gitattributes
git add . -u
git commit -m "Saving files before refreshing line endings"
git rm --cached -r .
git reset --hard
git add .
git commit -m "Normalize all the line endings"