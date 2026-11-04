# REA - install and usage notes (Ada)

## What is installed

- CLI `rea` from the official npm package **rea-agents 6.8.0**
  (https://www.npmjs.com/package/rea-agents, repo: https://github.com/morluto/rea).
- User-local prefix `~/.npm-global` (no sudo, no system changes).
- The GitHub fork https://github.com/Adalovelaceaut/rea is synced with
  upstream `morluto/rea` main (commit 47cedcc9, 2026-11-04).

## Version note (important)

- The installed npm release **6.8.0** corresponds to upstream tag
  `rea-agents-6.8.0`. The fork's main branch (47cedcc9) carries ~771 commits
  of post-6.8.0 fixes that are **not necessarily in the npm tarball** -
  upstream has not published a newer release yet.
- When upstream publishes a new release, update with: `rea update`
  (or `npm install --global --prefix ~/.npm-global rea-agents@latest`).

## Requirements

- Node.js >= 18 (tested: 22.x) and npm.
- Google Chrome/Chromium only for web capture commands.
- `rea doctor` reports Hopper/Ghidra/IDA/JADX as missing: expected and
  optional. They are only needed for native binary analysis. Web and
  JavaScript analysis work without them.

## Usage

Static analysis of a local JavaScript/Electron app directory:

    rea analyze-javascript-application /path/to/app --format json

Web capture + analysis. Chrome binds the debug port to loopback only, and
the browser is cleaned up via its PID with a trap, even on failure:

    google-chrome --headless=new \
      --remote-debugging-address=127.0.0.1 --remote-debugging-port=9333 \
      --user-data-dir=/tmp/rea-chrome --no-first-run https://TARGET &
    CHROME_PID=$!
    trap 'kill $CHROME_PID 2>/dev/null' EXIT
    sleep 4
    rea list-browser-targets http://127.0.0.1:9333 --format json   # find target_id
    rea analyze-web-bundle http://127.0.0.1:9333 <target_id> \
      --allowed-origins https://TARGET --format json

- Tested commands (analyze-javascript-application, list-browser-targets,
  analyze-web-bundle) were run against public pages without clicks or login;
  they observe the client side only. Other commands in `rea --help`
  (compare, decompile, screenshots, native debugging, etc.) have their own
  scopes and side effects - check each command's `--help` before using it.
- MCP registration (`npx rea-agents setup`) targets Claude Code/Codex-style
  agent hosts; the supported and tested usage here is the CLI.

## Reinstall from scratch

Run `rea-install.sh` (same directory). It pins 6.8.0, installs into the
user prefix, and self-tests with a local static analysis - it exits non-zero
if the self-test marker is missing. Verified on a clean prefix 2026-11-04.
