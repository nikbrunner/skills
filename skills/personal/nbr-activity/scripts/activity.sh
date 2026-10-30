#!/usr/bin/env bash
# Prints Nik's activity for one day, per circle. Every source emits JSON records, one per
# line; the formatter at the end prints them as text, or as one JSON array with --json.
# A failing source emits an error record and the others still run.
set -uo pipefail

usage() {
  echo "Usage: activity.sh YYYY-MM-DD [work|private|all] [--json]" >&2
  exit 1
}

JSON=""
ARGS=()
for arg in "$@"; do
  [[ "$arg" == --json ]] && JSON=1 || ARGS+=("$arg")
done
DAY="${ARGS[0]:-}"
CIRCLE="${ARGS[1]:-all}"
[[ "$DAY" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || usage
[[ "$CIRCLE" =~ ^(work|private|all)$ ]] || usage

SINCE="$(date -j -v-2d -f %F "$DAY" +%F)"
REPOS="$HOME/repos"
WORK_ROOT="$REPOS/imfusion"
AGENTS="$WORK_ROOT/brunner/agents"
ATLASSIAN="$AGENTS/skills/imfg-atlassian/scripts/atlassian.sh"
BITBUCKET_USER="brunner"

error() { jq -nc --arg circle "$1" --arg source "$2" --arg message "$3" '{$circle, $source, error: $message}'; }

# Primary checkouts only: `git log --all` already covers their linked worktrees.
repos_under() {
  local root="$1"
  shift
  find "$root" -maxdepth 5 \( -name node_modules "$@" \) -prune -o -type d -name .git -print 2>/dev/null |
    sed 's|/\.git$||' | sort
}

slug_of() {
  git -C "$1" remote get-url origin 2>/dev/null | sed -E 's|\.git$||; s|^.*[:/]([^/]+/[^/]+)$|\1|'
}

# collect_git CIRCLE ROOT "AUTHOR_ARGS" [find exclusions...]
collect_git() {
  local circle="$1" root="$2" authors="$3"
  shift 3
  local dir slug url
  repos_under "$root" "$@" | while read -r dir; do
    slug="$(slug_of "$dir")"
    url=""
    git -C "$dir" remote get-url origin 2>/dev/null | grep -q github.com && url="https://github.com/$slug"
    # shellcheck disable=SC2086
    git -C "$dir" log --all $authors --since="$SINCE" --date=format:'%F %H:%M' \
      --format='%H%x09%h%x09%ad%x09%s' 2>/dev/null |
      jq -Rc --arg circle "$circle" --arg day "$DAY" --arg repo "$(basename "$dir")" --arg slug "$slug" --arg url "$url" '
        split("\t") as [$hash, $short, $at, $subject]
        | select($at[0:10] == $day and $subject != "chore: backup")
        | {$circle, source: "git", $repo, $slug, time: $at[11:16], $hash, $short, $subject}
          + (if $url != "" then {url: "\($url)/commit/\($hash)"} else {} end)'
  done
}

collect_github() {
  command -v gh >/dev/null || { error private github "gh not installed"; return; }
  local user out kind
  user="$(gh api user --jq .login 2>&1)" || { error private github "$user"; return; }
  for kind in prs issues; do
    for when in created closed; do
      out="$(gh search "$kind" --author="$user" --"$when"="$DAY" --limit 100 \
        --json repository,number,title,state,url 2>&1)" || { error private github "$(head -1 <<<"$out")"; continue; }
      jq -c --arg kind "${kind%s}" '.[] | {circle: "private", source: "github", kind: $kind,
        slug: .repository.nameWithOwner, number, title, state: (.state | ascii_downcase), url}' <<<"$out"
    done
  done
}

collect_bitbucket() {
  command -v bkt >/dev/null || { error work bitbucket "bkt not installed"; return; }
  local prs
  prs="$(bkt api "/rest/api/latest/dashboard/pull-requests?limit=50&order=NEWEST" 2>&1)" ||
    { error work bitbucket "$(head -1 <<<"$prs")"; return; }
  jq -r --arg day "$DAY" '.values[]
    | select((.updatedDate / 1000 | strflocaltime("%F")) == $day)
    | [.toRef.repository.project.key, .toRef.repository.slug, .id, .author.user.name, .title, .links.self[0].href] | @tsv' <<<"$prs" |
    while IFS=$'\t' read -r project repo id author title url; do
      bkt api "/rest/api/latest/projects/$project/repos/$repo/pull-requests/$id/activities?limit=100" 2>/dev/null |
        jq -c --arg day "$DAY" --arg me "$BITBUCKET_USER" --arg author "$author" \
          --arg repo "$repo" --argjson number "$id" --arg title "$title" --arg url "$url" '
          [.values[]
            | select((.createdDate / 1000 | strflocaltime("%F")) == $day)
            | select(.action != "RESCOPED" and .action != "UPDATED")
            | if .user.name == $me then {action, by: null}
              elif $author == $me and (.action | IN("APPROVED", "MERGED", "DECLINED", "REVIEWED")) then {action, by: .user.name}
              else empty end]
          | group_by(.action, .by == null)
          | map(if .[0].by == null
                then (if length > 1 then "\(.[0].action) x\(length)" else .[0].action end)
                else "\(.[0].action) by \(map(.by) | unique | join(", "))" end)
          | select(length > 0)
          | {circle: "work", source: "bitbucket", $repo, $number, $title, actions: join(", "), $url}'
    done
}

collect_jira() {
  [[ -x "$ATLASSIAN" ]] || { error work jira "atlassian.sh not found"; return; }
  local keys out
  keys="$(grep -oE '\b(WEBSDK|CP)-[0-9]+' <<<"$1" | sort -u | paste -sd, -)"
  out="$("$ATLASSIAN" day "$DAY" "$keys" 2>&1)" || { error work jira "$(tail -1 <<<"$out")"; return; }
  [[ -z "$out" ]] && return
  jq -Rc 'split("\t") as [$key, $title, $change]
    | {circle: "work", source: "jira", $key, $title, $change, url: "https://imfusion.atlassian.net/browse/\($key)"}' <<<"$out"
}

collect() {
  if [[ "$CIRCLE" != work ]]; then
    jq -nc '{circle: "private", source: "heading"}'
    collect_git private "$REPOS" "--author=nbr --author=nikolaus.brunner@protonmail.ch" -o -path "$WORK_ROOT"
    collect_github
  fi
  if [[ "$CIRCLE" != private ]]; then
    jq -nc '{circle: "work", source: "heading"}'
    local git_out bitbucket_out
    git_out="$(collect_git work "$WORK_ROOT" "--author=Brunner" -o -path "$WORK_ROOT/brunner/notes")"
    bitbucket_out="$(collect_bitbucket)"
    printf '%s\n' "$git_out" "$bitbucket_out" | grep -v '^$'
    collect_jira "$git_out$bitbucket_out"
  fi
}

format_text() {
  jq -rs --arg day "$DAY" '
    def section($name; $lines): if ($lines | length) > 0 then ["## \($name)"] + $lines else [] end;
    group_by(.circle) | sort_by(.[0].circle != "private") | map(
      . as $all
      | [.[] | select(.error == null)] as $ok
      | ["# \($day) · \(.[0].circle)"]
      + section("git"; [$ok[] | select(.source == "git")] | group_by(.slug) | map(
          ["\(.[0].repo) (\(.[0].slug))"] + (sort_by(.time) | map("  \(.time) \(.short) \(.subject)"))) | add // [])
      + section("github"; [$ok[] | select(.source == "github")] | unique_by(.url)
          | map("  \(.slug) #\(.number) \(.title) · \(.state) · \(.url)"))
      + section("bitbucket"; [$ok[] | select(.source == "bitbucket")]
          | map("  \(.repo) #\(.number) \(.title) · \(.actions) · \(.url)"))
      + section("jira"; [$ok[] | select(.source == "jira")] | map("  \(.key) \(.title) · \(.change)"))
      + [$all[] | select(.error) | "! \(.source): \(.error)"]
    ) | flatten | .[]'
}

if [[ -n "$JSON" ]]; then
  collect | jq -s '[.[] | select(.source != "github" and .source != "heading")] + ([.[] | select(.source == "github")] | unique_by(.url))'
else
  collect | format_text
fi
