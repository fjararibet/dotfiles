{ pkgs, paths, ... }:

let
  instantclient = pkgs.symlinkJoin {
    name = "oracle-instantclient-joined";
    paths = with pkgs.oracle-instantclient; [
      out
      lib
      dev
    ];
  };
in
{
  imports = [ (paths.home + "/common.nix") ];
  home.packages = with pkgs; [
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.cloud-firestore-emulator ])
    jre
    oracle-instantclient
  ];
  home.file."instantclient".source = instantclient;
}
