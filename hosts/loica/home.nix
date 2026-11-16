{ paths, pkgs, lib, ... }:

{
  imports = [ (paths.home + "/common.nix") ];

  home.packages = [
    pkgs.awscli2
    pkgs.obsidian
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

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "orcen-jetspeed 3.135.179.190" = {
        HostName = "3.135.179.190";
        User = "ec2-user";
        IdentityFile = "~/.ssh/globeit.pem";
        IdentitiesOnly = true;
      };
      "coipo 32.190.129.202" = {
        HostName = "32.190.129.202";
        User = "fjara";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = true;
      };
    };
  };
}
