{pkgs}: let
  inherit (pkgs) lib;
  python = pkgs.python312;
  shellHook = ''
    unset PYTHONPATH
    export REPO_ROOT=$(git rev-parse --show-toplevel)
    source $REPO_ROOT/.venv/bin/activate
  '';

  mkPureShell = env:
    pkgs.mkShell {
      inherit (env) name;
      inherit shellHook;
      packages = [
        env
        pkgs.uv
      ];
    };

  mkImpureShell = pythonVersion:
    pkgs.mkShell {
      name = "impure";
      packages = [
        pythonVersion
        pkgs.uv
      ];
      env =
        {
          UV_PYTHON_DOWNLOADS = "never";
          UV_PYTHON = "${pythonVersion}/bin/python";
        }
        // lib.optionalAttrs pkgs.stdenv.isLinux {
          LD_LIBRARY_PATH = lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
        };

      inherit shellHook;
    };
in {
  default = mkPureShell pkgs.biaiEnv;
  pure = mkPureShell pkgs.biaiEnv;
  impure = mkImpureShell python;
}
