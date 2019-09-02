#!/bin/bash
set -e

git config --global user.email "ci@bit-clouded.com"

git pull --no-edit ../$internal master

if [[ `git diff --check` ]]; then
  echo 'Merge conflict!'
  exit 1
else
  echo 'no merge conflict detected'
fi

bash validate-templates.sh

if [$? -ne 0]
then
   echo "Validation failed!"
   exit 1
else
   echo "Validation passed!"
fi

if [[ `git status --porcelain` ]]; then
  git commit -m "merge"
  git push origin master
else
  echo 'no changes to commit'
fi