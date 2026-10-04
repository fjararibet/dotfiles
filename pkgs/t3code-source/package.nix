{
  lib,
  pkgs,
  src,
  makeWrapper,
  symlinkJoin,
  rustPlatform,
  fetchPnpmDeps,
  pnpm_11,
  libsecret,
  git,
  gh,
  codex,
  pi-coding-agent,
}:
let
  hashes = import ./dependencies.nix;
  upstreamVersion = (builtins.fromJSON (builtins.readFile "${src}/apps/server/package.json")).version;
  # Upstream recognizes nightly versions with a numeric final component.
  version = "${upstreamVersion}-nightly.${
    builtins.substring 0 8 src.lastModifiedDate
  }.${toString src.lastModified}";
  unwrapped = pkgs.t3code.unwrapped.overrideAttrs (old: {
    pname = "t3code-source-unwrapped";
    inherit src version;
    pnpmDeps = fetchPnpmDeps {
      pname = "t3code-source";
      inherit src version;
      pnpm = pnpm_11;
      inherit (old) pnpmWorkspaces;
      fetcherVersion = 4;
      hash = hashes.pnpmHash;
    };
    postPatch = old.postPatch + ''
      cp .env.example .env
      # Keep the keyring identity used by the official nightly desktop. The
      # visible name remains T3 Code (Nightly), independently of encryption.
      substituteInPlace apps/desktop/src/app/DesktopAppIdentity.ts \
        --replace-fail 'electronApp.setName(environment.displayName)' 'electronApp.setName("t3code")'
      substituteInPlace apps/desktop/package.json \
        --replace-fail '"productName": "T3 Code (Alpha)"' '"productName": "t3code"'
    '';
    preBuild = ''
      export npm_config_build_from_source=true
    ''
    + old.preBuild;
    meta = old.meta // {
      changelog = "https://github.com/pingdotgg/t3code/commits/${src.rev}";
    };
    postFixup = (old.postFixup or "") + ''
      substituteInPlace "$out/share/applications/t3code.desktop" \
        --replace-fail 'Name=T3 Code (Alpha)' 'Name=T3 Code (Nightly)'
    '';
  });
  resourceMonitor = rustPlatform.buildRustPackage {
    pname = "t3code-source-resource-monitor";
    inherit src version;
    sourceRoot = "source/native/resource-monitor";
    cargoLock.lockFile = "${src}/native/resource-monitor/Cargo.lock";
    meta = unwrapped.meta // {
      mainProgram = "t3-resource-monitor";
    };
  };
in
symlinkJoin {
  pname = "t3code-source";
  inherit version;
  paths = [ unwrapped ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    for program in t3 t3code-desktop; do
      wrapProgram "$out/bin/$program" \
        --prefix PATH : ${
          lib.makeBinPath [
            git
            gh
            codex
            pi-coding-agent
          ]
        } \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libsecret ]} \
        --set T3CODE_DISABLE_AUTO_UPDATE 1 \
        --set T3CODE_COMMIT_HASH ${src.rev} \
        --set-default T3CODE_RESOURCE_MONITOR_PATH ${lib.getExe resourceMonitor}
    done
  '';
  passthru = { inherit unwrapped resourceMonitor; };
  meta = unwrapped.meta // {
    description = "T3 Code nightly built from upstream source";
  };
}
