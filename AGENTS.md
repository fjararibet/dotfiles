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
