#!/usr/bin/env bash
# Restore the third-party skills from skills-lock.json, then link them and every skill in
# skills/<group>/ into one or more skill directories.
# Usage: ./setup.sh [target-dir...]   (default: ~/.agents/skills)
set -e

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

(cd "$repo" && npx -y skills experimental_install -y >/dev/null)

if [ $# -eq 0 ]; then
    set -- "$HOME/.agents/skills"
fi

for target in "$@"; do
    mkdir -p "$target"

    for link in "$target"/*; do
        if [ -L "$link" ] && [ ! -e "$link" ] && [[ "$(readlink "$link")" == "$repo"/* ]]; then
            rm "$link"
            echo "removed stale $link"
        fi
    done

    for skill in "$repo"/skills/*/*/ "$repo"/.agents/skills/*/; do
        [ -d "$skill" ] || continue
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
