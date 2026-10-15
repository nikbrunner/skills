#!/usr/bin/env bash
# Link every skill in skills/ into one or more skill directories.
# Usage: ./setup.sh [target-dir...]   (default: ~/.agents/skills)
set -e

repo_skills="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"

if [ $# -eq 0 ]; then
    set -- "$HOME/.agents/skills"
fi

for target in "$@"; do
    mkdir -p "$target"

    for link in "$target"/*; do
        if [ -L "$link" ] && [ ! -e "$link" ] && [[ "$(readlink "$link")" == "$repo_skills"/* ]]; then
            rm "$link"
            echo "removed stale $link"
        fi
    done

    for skill in "$repo_skills"/*/; do
        skill="${skill%/}"
        dest="$target/$(basename "$skill")"

        if [ -e "$dest" ] && [ ! -L "$dest" ]; then
            echo "skipped $dest: a real file or directory is in the way" >&2
            continue
        fi

        ln -sfn "$skill" "$dest"
        echo "linked $dest"
    done
done
