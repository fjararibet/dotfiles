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
