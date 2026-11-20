{ paths, pkgs, lib, ... }:

{
  imports = [ (paths.home + "/common.nix") ];

  home.packages = with pkgs; [
    awscli2
    spotify
    obsidian
    betterdisplay
  ];

  home.activation.installKeyboardLayout = lib.hm.dag.entryAfter [ "linkGeneration" ] (
    let
      layout = pkgs.fetchzip {
        url = "https://github.com/ajmasia/macos-us-altgr-intl/archive/refs/tags/v0.2.2.tar.gz";
        sha256 = "0xmvq1a2plarif00qz61blpcjdv0slqxv9x1cz56irhryb4f5adi";
      };
    in
    ''
      layout_dir="$HOME/Library/Keyboard Layouts"
      layout_bundle="$layout_dir/US AltGr Intl No Dead Keys.bundle"
      run mkdir -p "$layout_dir"
      # macOS needs a physical bundle here, rather than a Nix store symlink.
      if [ -L "$layout_bundle" ]; then
        run rm "$layout_bundle"
      fi
      run /usr/bin/ditto "${layout}/US AltGr Intl No Dead Keys.bundle" "$layout_bundle"
    ''
  );

  xdg.configFile."rex/init.lua".source = paths.config + "/rex/init.lua";

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "orcen-jetspeed" = {
        HostName = "3.135.179.190";
        User = "ec2-user";
        IdentityFile = "~/.ssh/globeit.pem";
        IdentitiesOnly = true;
      };
      "coipo" = {
        HostName = "32.190.129.202";
        User = "fjara";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = true;
      };
      "mlc-gps" = {
        HostName = "184.198.77.19";
        User = "ubuntu";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = true;
      };
      "qa2-cacapp" = {
        HostName = "3.136.4.245";
        User = "root";
        IdentityFile = "~/.ssh/rutasur.pem";
        IdentitiesOnly = true;
      };
      "qa2-cacdb" = {
        HostName = "18.223.148.47";
        User = "root";
        IdentityFile = "~/.ssh/rutasur.pem";
        IdentitiesOnly = true;
      };
      "qa2-crmfe" = {
        HostName = "3.17.122.214";
        User = "root";
        IdentityFile = "~/.ssh/bocrm.pem";
        IdentitiesOnly = true;
      };
      "bo-cacsv-qa" = {
        HostName = "13.58.8.95";
        User = "root";
        IdentityFile = "~/.ssh/bosv.pem";
        IdentitiesOnly = true;
      };
      "srv-crm-app" = {
        HostName = "172.16.48.233";
        IdentityFile = "~/.ssh/id_ed25519";
        User = "fjara";
      };
      "orcen-fe-dev" = {
        HostName = "107.22.43.104";
        User = "ubuntu";
        IdentityFile = "~/.ssh/orcendev.pem";
        IdentitiesOnly = true;
      };
    };
  };
}
