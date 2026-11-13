# NixOS builds and activation

Agents are authorized to build and apply this flake as part of requested
configuration changes, without asking for separate confirmation. Respect any
explicit request to only review, build, or leave changes unapplied. Activate only
the host in scope; do not deploy to other hosts unless requested.

From `/home/fjara/dotfiles`, build the local host's configuration without sudo:

```sh
nix build ".#nixosConfigurations.$(hostname).config.system.build.toplevel"
```

After a successful build, apply it using the passwordless sudo exemption:

```sh
sudo -n /run/current-system/sw/bin/nixos-rebuild switch --flake "/home/fjara/dotfiles#$(hostname)"
```

The exemption is for user `fjara` and matches the exact executable and arguments.
Use the absolute flake path and local hostname; additional flags are not covered.
The activation command rebuilds if necessary and switches the running system.

Each host needs one manual rebuild to install the exemption. If `sudo -n` reports
that a password is required, report that activation needs this manual bootstrap;
do not ask for a password in chat or store credentials. Report build and activation
results accurately, including when changes have not been activated.

# macOS builds and activation

For requested configuration changes on `loica`, agents are authorized to build
and apply the nix-darwin flake without separate confirmation. Respect explicit
requests to only build or leave changes unapplied.

From `/Users/fjara/dotfiles`, build without sudo:

```sh
nix build .#darwinConfigurations.loica.system
```

After a successful build, activate using the exact passwordless command:

```sh
sudo -n /run/current-system/sw/bin/darwin-rebuild switch --flake /Users/fjara/dotfiles#loica
```

The exemption is for `fjara`, runs as root, and matches only this executable and
these arguments. Additional flags are not covered. The first activation that
installs the exemption requires authenticated sudo. Report build and activation
results accurately.
