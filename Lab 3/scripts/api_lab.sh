#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$ROOT_DIR/data"
LOG_DIR="$ROOT_DIR/logs"
LOG_FILE="$LOG_DIR/lab3.log"
JOKE_URL="https://icanhazdadjoke.com/"
JOKE_FILE="$DATA_DIR/dad_joke.json"
JOKE_TEXT_FILE="$DATA_DIR/dad_joke.txt"
DECK_CREATE_FILE="$DATA_DIR/deck_create.json"
DECK_DRAW_FILE="$DATA_DIR/deck_draw.json"
DECK_SUMMARY_FILE="$DATA_DIR/deck_summary.txt"
LAB3_END_LOGGED=0

log() {
  printf '%s\n' "$1" >> "$LOG_FILE"
}

cleanup() {
  if [ "${LAB3_END_LOGGED:-0}" -eq 0 ]; then
    log "LAB3_END"
    LAB3_END_LOGGED=1
  fi
}
trap cleanup EXIT

mkdir -p "$DATA_DIR" "$LOG_DIR"
touch "$LOG_FILE"
if ! grep -qxF 'LAB3_START' "$LOG_FILE" >/dev/null 2>&1; then
  log "LAB3_START"
fi

for tool in curl jq; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Required tool '$tool' is missing." >&2
    exit 1
  fi
done

log "BASH_OK"

if ! http_code=$(curl -sS -H 'Accept: application/json' -o "$JOKE_FILE" -w '%{http_code}' "$JOKE_URL"); then
  log "CURL_JOKE_FAIL"
  echo "Failed to fetch Dad Jokes API." >&2
  exit 1
fi

if [ "$http_code" != "200" ]; then
  log "CURL_JOKE_FAIL"
  echo "Dad Jokes API returned HTTP $http_code" >&2
  exit 1
fi
log "CURL_JOKE_OK"

jq -r '.id, .joke' "$JOKE_FILE" > "$JOKE_TEXT_FILE"
log "JQ_JOKE_OK"

DECK_CREATE_URL="https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"
if ! deck_status=$(curl -sS -o "$DECK_CREATE_FILE" -w '%{http_code}' "$DECK_CREATE_URL"); then
  log "DECK_CREATE_FAIL"
  echo "Failed to create a deck." >&2
  exit 1
fi

if [ "$deck_status" != "200" ]; then
  log "DECK_CREATE_FAIL"
  echo "Deck creation failed with HTTP $deck_status" >&2
  exit 1
fi

DECK_ID="$(jq -r '.deck_id' "$DECK_CREATE_FILE")"
if [ -z "$DECK_ID" ] || [ "$DECK_ID" = "null" ]; then
  log "DECK_CREATE_FAIL"
  echo "Deck ID was not returned in the API response." >&2
  exit 1
fi
log "DECK_CREATE_OK"

DRAW_URL="https://deckofcardsapi.com/api/deck/${DECK_ID}/draw/?count=2"
if ! draw_status=$(curl -sS -o "$DECK_DRAW_FILE" -w '%{http_code}' "$DRAW_URL"); then
  log "DECK_DRAW_FAIL"
  echo "Failed to draw two cards." >&2
  exit 1
fi

if [ "$draw_status" != "200" ]; then
  log "DECK_DRAW_FAIL"
  echo "Card draw failed with HTTP $draw_status" >&2
  exit 1
fi
log "DECK_DRAW_OK"

jq -r '.cards[] | "\(.value) of \(.suit)"' "$DECK_DRAW_FILE" > "$DECK_SUMMARY_FILE"
remaining_cards="$(jq -r '.remaining' "$DECK_DRAW_FILE")"
printf 'Remaining cards: %s\n' "$remaining_cards" >> "$DECK_SUMMARY_FILE"
log "JQ_DECK_OK"

printf 'Script completed successfully.\n' >&2