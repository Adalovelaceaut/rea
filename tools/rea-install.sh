#!/usr/bin/env bash
# REA (rea-agents) installer - pinned to the verified release.
# Requires: Node.js >= 18 (tested on 22.x) and npm. Google Chrome/Chromium only
# needed for web capture commands. No sudo; installs into a user-local prefix.
set -euo pipefail

REA_VERSION="6.8.0"
PREFIX="${REA_PREFIX:-$HOME/.npm-global}"
SAMPLE=""

cleanup() {
  [ -n "$SAMPLE" ] && rm -rf "$SAMPLE"
}
trap cleanup EXIT

command -v node >/dev/null || { echo "node not found"; exit 1; }
command -v npm  >/dev/null || { echo "npm not found"; exit 1; }

npm install --global --prefix "$PREFIX" "rea-agents@${REA_VERSION}"
export PATH="$PREFIX/bin:$PATH"

echo "rea installed at: $PREFIX/bin/rea"
rea --version

# Sanity check: static analysis of a tiny local JavaScript sample.
SAMPLE="$(mktemp -d)"
mkdir -p "$SAMPLE/lib"
printf 'import { greet } from "./lib/greet.js";\nexport function main() { return greet("rea"); }\n' > "$SAMPLE/index.js"
printf 'export function greet(name) { return `hello ${name}`; }\n' > "$SAMPLE/lib/greet.js"
printf '{"name":"rea-sample","type":"module","version":"1.0.0"}\n' > "$SAMPLE/package.json"

if rea analyze-javascript-application "$SAMPLE" --format json \
     | grep -v rea_progress \
     | grep -q 'rea.javascript-application-analysis'; then
  echo "sanity check OK: static JS analysis works"
else
  echo "sanity check FAILED: expected evidence marker missing" >&2
  exit 1
fi

echo
echo "Add to your shell profile:  export PATH=\"$PREFIX/bin:\$PATH\""
echo "Optional native engines (Hopper/Ghidra/IDA/JADX) are only needed for"
echo "native binary analysis; web/JS analysis works without them."
