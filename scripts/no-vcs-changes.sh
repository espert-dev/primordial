#!/bin/sh
set -eu

git add .

if ! (git diff --quiet && git diff --cached --quiet); then
  echo -e "\e[31mChanges to version-controlled files detected!\e[0m\n"
  git status
  git diff || :
  git diff --cached || :
  exit 1
fi

exit 0
