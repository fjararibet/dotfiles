"""Refresh the pnpm fixed-output hash for the already locked source revision."""

import json
from pathlib import Path
import re
import subprocess
import sys


def main():
    root = Path.cwd()
    if (root / "pkgs/t3code-source/package.nix").is_file():
        pin = root / "pkgs/t3code-source/dependencies.nix"
        package = "t3code-nightly"
    elif (root / "package.nix").is_file() and (root / "dependencies.nix").is_file():
        pin = root / "dependencies.nix"
        package = "default"
    else:
        raise RuntimeError("Run from the dotfiles root or the standalone t3code-source flake.")

    expression = f'''
      let
        flake = builtins.getFlake {json.dumps(str(root))};
        deps = flake.packages.${{builtins.currentSystem}}.{package}.unwrapped.pnpmDeps;
      in deps.overrideAttrs {{
        outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      }}
    '''
    result = subprocess.run(
        ["nix", "build", "--impure", "--no-link", "--expr", expression],
        text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
    )
    matches = re.findall(r"got:\s+(sha256-[A-Za-z0-9+/]+={0,2})", result.stdout)
    if result.returncode == 0 or len(matches) != 1:
        sys.stdout.write(result.stdout)
        raise RuntimeError("Could not determine the pnpm hash; dependency fetching must succeed first.")
    content = '{\n  pnpmHash = "' + matches[0] + '";\n}\n'
    if pin.read_text() == content:
        print("The pnpm dependency hash is already current.")
        return
    temporary = pin.with_suffix(".nix.tmp")
    temporary.write_text(content)
    temporary.replace(pin)
    print(f"Updated {pin.relative_to(root)}. Build the package to verify the source update.")


if __name__ == "__main__":
    try:
        main()
    except RuntimeError as error:
        sys.exit(str(error))
