#!/usr/bin/env bash
# Prints Nik's private activity for one day: commits across ~/repos and GitHub PRs and issues.
# Every source emits JSON records, one per line; the formatter at the end prints them as text,
# or as one JSON array with --json. A failing source emits an error record and the others still run.
set -uo pipefail

usage() {
  echo "Usage: activity.sh YYYY-MM-DD [--json]" >&2
  exit 1
}

JSON=""
DAY=""
for arg in "$@"; do
  [[ "$arg" == --json ]] && JSON=1 || DAY="$arg"
done
[[ "$DAY" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || usage

SINCE="$(date -j -v-2d -f %F "$DAY" +%F)"
ROOT="$HOME/repos"
AUTHORS=(--author=nbr --author=nikolaus.brunner@protonmail.ch)

error() { jq -nc --arg source "$1" --arg message "$2" '{circle: "private", $source, error: $message}'; }

# Primary checkouts only: `git log --all` already covers their linked worktrees.
collect_git() {
  local dir slug url
  find "$ROOT" -maxdepth 5 -name node_modules -prune -o -type d -name .git -print 2>/dev/null |
    sed 's|/\.git$||' | sort |
    while read -r dir; do
      slug="$(git -C "$dir" remote get-url origin 2>/dev/null | sed -E 's|\.git$||; s|^.*[:/]([^/]+/[^/]+)$|\1|')"
      url=""
      git -C "$dir" remote get-url origin 2>/dev/null | grep -q github.com && url="https://github.com/$slug"
      git -C "$dir" log --all "${AUTHORS[@]}" --since="$SINCE" --date=format:'%F %H:%M' \
        --format='%H%x09%h%x09%ad%x09%s' 2>/dev/null |
        jq -Rc --arg day "$DAY" --arg repo "$(basename "$dir")" --arg slug "$slug" --arg url "$url" '
          split("\t") as [$hash, $short, $at, $subject]
          | select($at[0:10] == $day and $subject != "chore: backup")
          | {circle: "private", source: "git", $repo, $slug, time: $at[11:16], $hash, $short, $subject}
            + (if $url != "" then {url: "\($url)/commit/\($hash)"} else {} end)'
    done
}

collect_github() {
  command -v gh >/dev/null || { error github "gh not installed"; return; }
  local user out kind when
  user="$(gh api user --jq .login 2>&1)" || { error github "$user"; return; }
  for kind in prs issues; do
    for when in created closed; do
      out="$(gh search "$kind" --author="$user" --"$when"="$DAY" --limit 100 \
        --json repository,number,title,state,url 2>&1)" || { error github "$(head -1 <<<"$out")"; continue; }
      jq -c --arg kind "${kind%s}" '.[] | {circle: "private", source: "github", kind: $kind,
        slug: .repository.nameWithOwner, number, title, state: (.state | ascii_downcase), url}' <<<"$out"
    done
  done
}

collect() {
  collect_git
  collect_github | jq -sc 'unique_by(.url) | .[]'
}

format_text() {
  jq -rs --arg day "$DAY" '
    def section($name; $lines): if ($lines | length) > 0 then ["## \($name)"] + $lines else [] end;
    [.[] | select(.error == null)] as $ok
    | ["# \($day) · private"]
    + section("git"; [$ok[] | select(.source == "git")] | group_by(.slug) | map(
        ["\(.[0].repo) (\(.[0].slug))"] + (sort_by(.time) | map("  \(.time) \(.short) \(.subject)"))) | add // [])
    + section("github"; [$ok[] | select(.source == "github")]
        | map("  \(.slug) #\(.number) \(.title) · \(.state) · \(.url)"))
    + [.[] | select(.error) | "! \(.source): \(.error)"]
    | .[]'
}

if [[ -n "$JSON" ]]; then
  collect | jq -s .
else
  collect | format_text
fi
