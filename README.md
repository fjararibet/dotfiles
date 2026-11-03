Dotfiles managed using stow

# NixOS activation

After one manual rebuild installs the sudo rule on each host, agents running as
`fjara` can activate that host's configuration without a password:

```sh
sudo -n /run/current-system/sw/bin/nixos-rebuild switch --flake "/home/fjara/dotfiles#$(hostname)"
```

The sudo exemption matches this exact command and arguments. Use the absolute
flake path and the local hostname; additional flags are not covered. For the
initial manual rebuild, run the same command without `-n` and enter your password.
An agent that can edit and activate this flake effectively has root access.

# T3 Code nightly

The flake uses the nightly package directly from `github:limwa/nix-t3code`, pinned
in `flake.lock`.

Update and build the nightly:

```sh
nix flake update t3code
nix build .#t3code-nightly
```

Run the CLI or desktop:

```sh
nix run .#t3code-nightly -- --version
nix run .#t3code-desktop-nightly
```

On **huala**, both `fjara` and `ale` instead install T3 Code independently with
`nix profile add`. It is not a dependency of that host's system or Home Manager
build. Activation bootstraps a missing profile installation at the previously
deployed revision, without upgrading an existing installation. Other hosts still
use the flake's packaged version.

The CLI, desktop launcher, and user service use `~/.nix-profile`. Existing
`~/.t3` data, credentials, and settings stay in place; the services retain ports
3773 (`fjara`) and 3774 (`ale`), and still start at boot via lingering.

To move from the migration's pinned version to the latest nightly, run as the
account whose installation you want to update:

```sh
nix profile remove t3code-nightly
nix profile add github:limwa/nix-t3code#t3code-nightly
systemctl --user restart t3code
```

After that one-time move to the unpinned URL, future updates need no rebuild:

```sh
nix profile upgrade t3code-nightly
systemctl --user restart t3code
```

The migration version can be reinstalled with:

```sh
nix profile add github:limwa/nix-t3code/e024ef5edfa4cbff3fe681c18782029a5381637d#t3code-nightly
```

# Initial setup

```zsh
setopt EXTENDED_GLOB
stow --dotfiles --restow ^(Backgrounds|nixos)
```

# GNOME

Map Caps Lock to Control for the current user:

```sh
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"
```

Restore the default Caps Lock behavior:

```sh
gsettings reset org.gnome.desktop.input-sources xkb-options
```
