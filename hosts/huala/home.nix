{ config, inputs, pkgs, paths, ... }:
let
  profileBin = "${config.home.homeDirectory}/.nix-profile/bin";
  providerPath = "PATH=${profileBin}:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin";
  # r2modman calls steam -applaunch synchronously from Electron's main process.
  r2modmanSteam = pkgs.writeShellScriptBin "steam" ''
    if [[ "$1" == -applaunch ]]; then
      /run/current-system/sw/bin/steam "$@" </dev/null >/dev/null 2>&1 &
      exit 0
    fi
    exec /run/current-system/sw/bin/steam "$@"
  '';
  r2modman = pkgs.symlinkJoin {
    name = "r2modman-huala";
    paths = [ pkgs.r2modman ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/r2modman --prefix PATH : ${r2modmanSteam}/bin
    '';
  };
  zapzapWayland = pkgs.symlinkJoin {
    name = "zapzap-wayland";
    paths = [ pkgs.zapzap ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/zapzap --set QT_QPA_PLATFORM wayland
    '';
  };
in {
  disabledModules = [ "${inputs.home-manager}/modules/programs/t3code.nix" ];
  imports = [
    inputs.home-manager-t3code.outPath
    (paths.home + "/common.nix")
    (paths.home + "/desktop.nix")
  ];

  # Keep T3 Code independently updatable through fjara's Nix profile.
  programs.t3code = {
    enable = true;
    package = pkgs.writeShellScriptBin "t3" ''
      exec "${profileBin}/t3" "$@"
    '';
    server.enable = true;
  };

  # Manage the user-local entry so T3 Code cannot replace it with its own launcher.
  xdg.dataFile."applications/com.t3tools.T3Code.desktop".source = "${pkgs.makeDesktopItem {
    name = "com.t3tools.T3Code";
    desktopName = "T3 Code (Alpha)";
    comment = "Minimal web GUI for coding agents";
    exec = "env T3CODE_HOME=${config.home.homeDirectory}/.t3-desktop ${profileBin}/t3code-desktop %U";
    icon = "t3code";
    terminal = false;
    categories = [ "Development" ];
    mimeTypes = [ "x-scheme-handler/t3code" ];
    extraConfig.StartupWMClass = "t3code";
  }}/share/applications/com.t3tools.T3Code.desktop";

  # Keep profile-installed provider CLIs available to the upstream unit.
  systemd.user.services.t3code.Service = {
    WorkingDirectory = "%h";
    Environment = [
      "T3CODE_HOME=${config.home.homeDirectory}/.t3"
      providerPath
    ];
  };

  systemd.user.services.paseo = {
    Unit.Description = "Paseo daemon";
    Service = {
      ExecStart = "${pkgs.unstable.paseo}/bin/paseo daemon run";
      Environment = [ providerPath ];
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  home.packages = with pkgs; [
    qbittorrent
    cloudflared
    zapzapWayland
    r2modman
    unstable.osu-lazer-bin
    unstable.google-cloud-sdk
    unstable.paseo
    unstable.paseo-desktop
  ];
}
