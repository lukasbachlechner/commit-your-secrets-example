#!/usr/bin/env bash
# Decrypt secrets/dev.yaml into the environment, then exec whatever you were
# going to run anyway. Nothing is ever written to disk.
set -euo pipefail

SECRETS="secrets/dev.yaml"

# This repo ships its own age key on purpose (see keys/README). On a real repo
# you'd delete these two lines and let sops find ~/.config/sops/age/keys.txt.
if [ -z "${SOPS_AGE_KEY_FILE:-}" ] && [ -f keys/demo-key.txt ]; then
  export SOPS_AGE_KEY_FILE=keys/demo-key.txt
fi

if [ ! -f "$SECRETS" ]; then
  # Migration path: a plaintext .env keeps working while a team switches over.
  [ -f .env ] && set -a && . ./.env && set +a
  exec "$@"
fi

if ! command -v sops >/dev/null; then
  echo "sops is not installed. brew install sops age" >&2
  exit 1
fi

if ! out=$(sops decrypt --output-type dotenv "$SECRETS" 2>&1); then
  echo "Could not decrypt $SECRETS:" >&2
  echo "$out" >&2
  echo "Run \"pnpm keygen\" to make an age key," >&2
  echo "and its public half in .sops.yaml — ask a teammate to add it." >&2
  exit 1
fi

# ponytail: one KEY=VALUE per line; a value with a newline in it would need
# --output-type json and a real parser.
while IFS= read -r line; do
  [ -n "$line" ] && export "$line"
done <<< "$out"

exec "$@"
