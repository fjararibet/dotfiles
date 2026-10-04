# T3 Code source nightly flake

A standalone flake for Linux x64 and ARM64. Copy this directory to its own
repository to publish it independently. It builds T3 Code's desktop, server/web
UI, browser-secret helper, and Rust resource monitor from the source pinned in
`flake.lock`, adapting nixpkgs' source derivation. The terminal addon is rebuilt
from source too. Electron, Node, build tools, and third-party npm dependencies
come from nixpkgs/the pnpm dependency fetcher; this does not build Electron or
every third-party dependency from source.

```sh
nix build ./pkgs/t3code-source
nix run ./pkgs/t3code-source#desktop
nix run ./pkgs/t3code-source#t3 -- --version
nix flake check ./pkgs/t3code-source
```

The version is upstream's package version plus `nightly.<commit-date>.<commit-timestamp>`;
the upstream commit is also embedded for diagnostics. This tracks upstream's
default development branch, rather than downloading an official nightly release.

## Updates in these dotfiles

The parent flake supplies the source and nixpkgs inputs, so its `flake.lock` is
authoritative for installed packages:

```sh
nix flake update t3code-src
nix build .#t3code-nightly
```

If upstream changed JavaScript dependencies, refresh their fixed-output hash and
retry the build:

```sh
nix run ./pkgs/t3code-source#refresh-dependencies
nix build .#t3code-nightly
```

The helper only refreshes dependencies for the locked source; it does not discover
releases or update source inputs. Cargo dependencies are pinned directly by
upstream's `Cargo.lock`. Review the lock/hash changes before rebuilding NixOS.

## Updates as an independent flake

From this directory (or its own repository):

```sh
nix flake update t3code-src
nix run .#refresh-dependencies
nix flake check
nix build
```

Commit the source lock and dependency hash together after verification. Consumers
can then use this repository as a normal flake input and update that input.

T3 Connect's public production build configuration is enabled. Both executables
include Git, GitHub CLI, Codex, and Pi on PATH. Application self-updates are
disabled. The desktop retains the official nightly's `t3code` keyring identity
and existing user-data locations, independent of its visible display name.
