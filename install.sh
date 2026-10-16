#!/usr/bin/env bash
# Restore the third-party skills from skills-lock.json, link them and every skill in skills/<group>/
# into ~/.agents/skills, and point the Claude Code skill directories at it.
set -e

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="$HOME/.agents/skills"

(cd "$repo" && npx -y skills experimental_install -y >/dev/null)

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

for home in "$HOME/.claude" "$HOME/.claude-work"; do
    [ -d "$home" ] || continue
    dest="$home/skills"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "skipped $dest: a real file or directory is in the way" >&2
        continue
    fi

    ln -sfn "$target" "$dest"
    echo "linked $dest"
done
