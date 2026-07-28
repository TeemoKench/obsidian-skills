#!/usr/bin/env bash
# Sync this fork from kepano/obsidian-skills and enforce fork policy.
# Used by GitHub Actions (.github/workflows/sync-upstream.yml).
# Can also be run locally from a clean checkout of TeemoKench/obsidian-skills.
set -euo pipefail

UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/kepano/obsidian-skills.git}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-main}"
TARGET_BRANCH="${TARGET_BRANCH:-main}"

log() { echo "[sync-upstream] $*"; }
die() { echo "[sync-upstream] ERROR: $*" >&2; exit 1; }

root="$(git rev-parse --show-toplevel 2>/dev/null)" || die "not inside a git repo"
cd "$root"

git config user.name "${GIT_AUTHOR_NAME:-github-actions[bot]}"
git config user.email "${GIT_AUTHOR_EMAIL:-41898282+github-actions[bot]@users.noreply.github.com}"

if ! git remote get-url upstream >/dev/null 2>&1; then
  git remote add upstream "$UPSTREAM_URL"
else
  git remote set-url upstream "$UPSTREAM_URL"
fi

log "fetch upstream/$UPSTREAM_BRANCH"
git fetch --no-tags upstream "$UPSTREAM_BRANCH"

before_full="$(git rev-parse HEAD)"
before="$(git rev-parse --short HEAD)"
upstream_full="$(git rev-parse "upstream/$UPSTREAM_BRANCH")"
upstream_short="$(git rev-parse --short "upstream/$UPSTREAM_BRANCH")"

merged=0
if git merge-base --is-ancestor "$upstream_full" HEAD; then
  log "already contains upstream/$UPSTREAM_BRANCH ($upstream_short)"
else
  log "merging upstream/$UPSTREAM_BRANCH $upstream_short (was $before)"
  if ! git merge --no-edit "upstream/$UPSTREAM_BRANCH" \
      -m "chore: merge upstream kepano/obsidian-skills ($upstream_short)"; then
    git merge --abort 2>/dev/null || true
    die "merge upstream failed (conflicts?). HEAD was $before; upstream $upstream_short"
  fi
  merged=1
fi

changed=0

# Policy: never ship obsidian-cli
if [[ -e skills/obsidian-cli ]]; then
  rm -rf skills/obsidian-cli
  log "removed skills/obsidian-cli"
  changed=1
fi

ALLOWED='defuddle json-canvas obsidian-bases obsidian-markdown obsidian-user-vault'
if [[ -d skills ]]; then
  for d in skills/*; do
    [[ -e "$d" ]] || continue
    base="$(basename "$d")"
    if [[ "$base" == "obsidian-cli" ]]; then
      rm -rf "$d"
      changed=1
      continue
    fi
    case " $ALLOWED " in
      *" $base "*) ;;
      *) log "NOTE: unexpected skill dir kept: $base" ;;
    esac
  done
fi

# README: drop skill-table rows that reintroduce cli (keep "cli removed" policy text)
if [[ -f README.md ]]; then
  tmp="$(mktemp)"
  grep -v -E '^\|[[:space:]]*\[obsidian-cli\]|^\|[^|]*skills/obsidian-cli|^\- \[obsidian-cli\]' README.md >"$tmp" || true
  if ! cmp -s README.md "$tmp"; then
    mv "$tmp" README.md
    log "stripped obsidian-cli skill rows from README.md"
    changed=1
  else
    rm -f "$tmp"
  fi
fi

# Restore fork banner if upstream overwrite removed it
if [[ -f README.md ]] && ! grep -q 'TeemoKench fork' README.md; then
  tmp="$(mktemp)"
  {
    echo "# Obsidian Skills (TeemoKench fork)"
    echo
    echo "Fork of [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) with customizations:"
    echo "- **\`obsidian-cli\` removed** (not used here)"
    echo "- kepano four kept: markdown / bases / json-canvas / defuddle"
    echo "- may include **\`obsidian-user-vault\`** (local vault playbook)"
    echo
    awk 'BEGIN{skip=0} /^# / && !skip {skip=1; next} {print}' README.md
  } >"$tmp"
  mv "$tmp" README.md
  changed=1
  log "restored fork banner on README.md"
fi

# Keep vault skill listed if directory exists
if [[ -d skills/obsidian-user-vault && -f README.md ]] && ! grep -q 'obsidian-user-vault' README.md; then
  row='| [obsidian-user-vault](skills/obsidian-user-vault) | Portable vault playbook: resolve path via `local-config`/env, PARA, no-space names, `createBy`/`updateBy`, **headless Sync gate before writes** |'
  if grep -q '^\| \[defuddle\]' README.md; then
    tmp="$(mktemp)"
    awk -v row="$row" '/^\| \[defuddle\]/ {print; print row; next} {print}' README.md >"$tmp"
    mv "$tmp" README.md
    changed=1
    log "re-added obsidian-user-vault row to README.md"
  fi
fi

if [[ "$changed" -eq 1 ]] || ! git diff --quiet || ! git diff --cached --quiet; then
  git add -A
  if ! git diff --cached --quiet; then
    git commit -m "chore: drop obsidian-cli after upstream sync (fork policy)"
    changed=1
  fi
fi

after_full="$(git rev-parse HEAD)"
after="$(git rev-parse --short HEAD)"
skills_list="$(ls -1 skills 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//')"

pushed=0
if [[ "$after_full" != "$before_full" ]]; then
  log "push $TARGET_BRANCH → $after"
  git push origin "HEAD:$TARGET_BRANCH"
  pushed=1
else
  log "no commit changes (HEAD $after); nothing to push"
fi

# GitHub Actions job summary / outputs
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "## obsidian-skills upstream sync"
    echo
    echo "- upstream: \`kepano/obsidian-skills@$upstream_short\`"
    echo "- before → after: \`$before\` → \`$after\`"
    echo "- merged_upstream: \`$merged\`"
    echo "- pushed: \`$pushed\`"
    echo "- skills: \`$skills_list\`"
  } >>"$GITHUB_STEP_SUMMARY"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "merged=$merged"
    echo "pushed=$pushed"
    echo "before=$before"
    echo "after=$after"
    echo "upstream=$upstream_short"
    echo "skills=$skills_list"
  } >>"$GITHUB_OUTPUT"
fi

if [[ "$merged" -eq 1 || "$pushed" -eq 1 ]]; then
  log "done: updated ($before → $after); skills: $skills_list"
else
  log "done: already up to date ($after); upstream=$upstream_short; skills: $skills_list"
fi
