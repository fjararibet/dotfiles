Dotfiles managed using stow

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
