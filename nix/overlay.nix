{inputs, ...}: pkgs: super: let
  inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;
  inherit (pkgs) lib stdenv;

  workspace = uv2nix.lib.workspace.loadWorkspace {workspaceRoot = ../.;};

  envOverlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  pyprojectOverrides = import ./pyproject-overrides.nix {inherit pkgs;};

  mkDepsOnlyEnv = python: let
    inherit (stdenv) targetPlatform;

    pythonSet =
      (pkgs.callPackage pyproject-nix.build.packages {
        inherit python;
        stdenv = stdenv.override {
          targetPlatform =
            targetPlatform
            // lib.optionalAttrs targetPlatform.isDarwin {
              darwinSdkVersion =
                if targetPlatform.isAarch64
                then "14.0"
                else "12.0";
            };
        };
      }).overrideScope (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.default
          envOverlay
          pyprojectOverrides
        ]
      );

    externalDeps =
      lib.filterAttrs
      (name: _: name != "project-name" && name != "biai-session")
      (workspace.deps.default or {});
  in
    pythonSet.mkVirtualEnv "BIAI-${python.pythonVersion}" externalDeps;
in
  super
  // {
    biaiEnv = mkDepsOnlyEnv pkgs.python312;
    biaiDevEnv = mkDepsOnlyEnv pkgs.python312;
  }
