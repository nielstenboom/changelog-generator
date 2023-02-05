#!/bin/bash
set -eou pipefail

head_ref=$1
base_ref=$2
repo_url=$3
extra_flags=""

if [ "$4" == "true" ]; then
  extra_flags='--reverse'
fi

# By default a GitHub action checkout is shallow. Get all the tags, branches,
# and history. Redirect output to standard error which we can collect in the
# action.
# git fetch --depth=2 origin +refs/tags/*:refs/tags/* 1>&2
# git fetch --no-tags --prune --depth=1 origin +refs/heads/*:refs/remotes/origin/* 1>&2
# for d in .git/refs/heads/*; do
#   dir=$(basename "${d}")
#   git fetch --no-tags --prune --depth=1 origin +refs/heads/"${dir}"/*:refs/remotes/origin/"${dir}"/* 1>&2
# done
git fetch --prune --unshallow origin 1>&2

# if folks don't have a base ref to compare against just use the initial
# commit. This will show all the changes since the beginning but I can't
# think of a better default.
if [ -z "$base_ref" ]
then
  base_ref=$(git rev-list --max-parents=0 HEAD)
fi

# git log test/branch

# git checkout "${base_ref}"

# Bash quoting will get you. Do not quote the extra_flags. If its null
# we want it to disappear. If you quote it, it will go to git as an ""
# and thats not a valid arg.
log=$(git log "${base_ref}"..."${head_ref}" \
  --pretty=format:"- [%h](http://github.com/${repo_url}/commit/%H) - %s" \
  ${extra_flags})

if [ -z "$log" ];
then
  log="No Changes."
fi

echo "$log"