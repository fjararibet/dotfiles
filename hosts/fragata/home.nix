{ lib, pkgs, paths, ... }:

{
  imports = [
    (paths.home + "/common.nix")
    (paths.home + "/desktop.nix")
  ];

  # Prefer NVIDIA for applications, including those launched through Walker.
  home.sessionVariables = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };

  # Render on the GPU wired to HDMI, avoiding Intel-to-NVIDIA frame copies.
  # Use the PCI path because renderD* numbering can change across boots.
  xdg.configFile."niri/config.kdl".source = lib.mkForce (pkgs.writeText "niri-fragata-config.kdl" (
    builtins.readFile (paths.config + "/niri/config.kdl") + ''

      debug {
          render-drm-device "/dev/dri/by-path/pci-0000:01:00.0-render"
      }
    ''
  ));

  home.packages = with pkgs; [
    zapzap
  ];
}
