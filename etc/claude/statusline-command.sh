#!/usr/bin/env bash
# Claude Code status line: model display name + context window usage bar
# + plan/session rate limit usage (Claude.ai subscription only, when available)
# + per-model weekly limits such as Fable (from the usage API, cached)

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
has_rate_limits=$(printf '%s' "$input" | jq -r 'if .rate_limits then 1 else empty end')
five_hour=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_resets_at=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_resets_at=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

if [ -z "$used" ]; then
  used_int=0
else
  used_int=$(printf '%.0f' "$used")
fi

now_epoch=$(date +%s)

dim=$'\033[2m'
reset=$'\033[0m'

# Build a colored "[███░░░░░░░] NN%" progress bar for a given percentage.
make_bar() {
  local pct=$1
  local width=${2:-10}
  local filled=$(( pct * width / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0
  local empty=$(( width - filled ))

  local bar=""
  for ((i = 0; i < filled; i++)); do bar="${bar}█"; done
  for ((i = 0; i < empty; i++)); do bar="${bar}░"; done

  local color
  if [ "$pct" -ge 80 ]; then
    color=$'\033[2;31m'
  elif [ "$pct" -ge 50 ]; then
    color=$'\033[2;33m'
  else
    color=$'\033[2;32m'
  fi

  printf "${color}[%s] %s%%${reset}" "$bar" "$pct"
}

# Per-model weekly limits (e.g. Fable) are not part of the status line input.
# They come from the endpoint behind /usage, which is undocumented and may
# change. The response is cached and refreshed in the background, so the
# status line never waits on the network; a failed fetch just drops the segment.
usage_api_url='https://api.anthropic.com/api/oauth/usage'
usage_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"
usage_cache="$usage_cache_dir/usage.json"
usage_stamp="$usage_cache_dir/usage.stamp"  # mtime = last fetch attempt
usage_refresh_secs=60
usage_max_age_secs=3600

file_mtime() {
  stat -c %Y "$1" 2>/dev/null || echo 0
}

refresh_usage() {
  local creds="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.credentials.json"
  local token expires_ms tmp

  token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds" 2>/dev/null)
  expires_ms=$(jq -r '.claudeAiOauth.expiresAt // 0' "$creds" 2>/dev/null)
  [ -n "$token" ] || return 1
  # Claude Code refreshes an expired token itself; wait for it to do so.
  [ $(( ${expires_ms%.*} / 1000 )) -gt "$(date +%s)" ] || return 1

  tmp=$(mktemp "$usage_cache_dir/usage.XXXXXX") || return 1
  # Pass the token through stdin so it never appears in the process list.
  if printf 'Authorization: Bearer %s\n' "$token" |
       curl -fsS -m 10 -H @- -H 'anthropic-beta: oauth-2025-04-20' \
         -o "$tmp" "$usage_api_url" &&
     jq -e '.limits | type == "array"' "$tmp" >/dev/null; then
    mv -f "$tmp" "$usage_cache"
  else
    rm -f "$tmp"
    return 1
  fi
}

if [ -n "$has_rate_limits" ] && mkdir -p "$usage_cache_dir" 2>/dev/null; then
  if [ $(( now_epoch - $(file_mtime "$usage_stamp") )) -ge "$usage_refresh_secs" ]; then
    touch "$usage_stamp"
    ( refresh_usage ) </dev/null >/dev/null 2>&1 &
  fi
fi

bar_width=10
line=$(printf "${dim}%s${reset} %s" "$model" "$(make_bar "$used_int" "$bar_width")")

# Plan/session usage limits: rate_limits.five_hour / rate_limits.seven_day.
# These are only present for Claude.ai subscription plans, and only after the
# first API response in the session (absent for API-key/console billing).
# Each limit is rendered as its own "|"-separated segment:
#   <label> (<reset time>) [bar] NN%
segments=()

if [ -n "$five_hour" ]; then
  five_int=$(printf '%.0f' "$five_hour")
  five_seg="${dim}5h${reset}"

  if [ -n "$five_hour_resets_at" ]; then
    remaining=$(( ${five_hour_resets_at%.*} - now_epoch ))
    if [ "$remaining" -gt 0 ]; then
      rem_h=$(( remaining / 3600 ))
      rem_m=$(( (remaining % 3600) / 60 ))
      five_seg="${five_seg} ${dim}$(printf '(%d:%02d)' "$rem_h" "$rem_m")${reset}"
    fi
  fi

  five_seg="${five_seg} $(make_bar "$five_int" "$bar_width")"
  segments+=("$five_seg")
fi

seven_reset_fmt=""
if [ -n "$seven_day" ]; then
  seven_int=$(printf '%.0f' "$seven_day")
  seven_seg="${dim}7d${reset}"

  if [ -n "$seven_day_resets_at" ]; then
    seven_reset_fmt=$(date -d "@${seven_day_resets_at%.*}" "+%m/%d %H:%M" 2>/dev/null)
    [ -n "$seven_reset_fmt" ] && seven_seg="${seven_seg} ${dim}(${seven_reset_fmt})${reset}"
  fi

  seven_seg="${seven_seg} $(make_bar "$seven_int" "$bar_width")"
  segments+=("$seven_seg")
fi

# Per-model weekly limits from the cached usage response, one segment each.
# The reset time is shown only when it differs from the 7d one by > 5 minutes.
if [ -n "$has_rate_limits" ] && [ -r "$usage_cache" ] &&
   [ $(( now_epoch - $(file_mtime "$usage_cache") )) -le "$usage_max_age_secs" ]; then
  while IFS=$'\t' read -r scoped_name scoped_pct scoped_resets_at; do
    scoped_seg="${dim}${scoped_name}${reset}"

    if [ -n "$scoped_resets_at" ]; then
      scoped_epoch=$(date -d "$scoped_resets_at" +%s 2>/dev/null) || continue
      # A stale cache may still hold a window that has already reset.
      [ "$scoped_epoch" -gt "$now_epoch" ] || continue
      # The server's reset timestamps jitter by a second or so between calls.
      show_reset=1
      if [ -n "$seven_reset_fmt" ]; then
        reset_gap=$(( scoped_epoch - ${seven_day_resets_at%.*} ))
        [ "${reset_gap#-}" -le 300 ] && show_reset=
      fi
      if [ -n "$show_reset" ]; then
        scoped_reset_fmt=$(date -d "@${scoped_epoch}" "+%m/%d %H:%M")
        scoped_seg="${scoped_seg} ${dim}(${scoped_reset_fmt})${reset}"
      fi
    fi

    scoped_seg="${scoped_seg} $(make_bar "$(printf '%.0f' "$scoped_pct")" "$bar_width")"
    segments+=("$scoped_seg")
  done < <(jq -r '
    .limits[]
    | select(.kind == "weekly_scoped" and .scope.model.display_name != null)
    | [.scope.model.display_name, .percent, (.resets_at // "")]
    | @tsv' "$usage_cache" 2>/dev/null)
fi

for seg in "${segments[@]}"; do
  line="${line} ${dim}|${reset} ${seg}"
done

printf '%s\n' "$line"
