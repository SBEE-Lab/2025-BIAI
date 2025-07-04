{pkgs}: final: prev: let
  inherit (pkgs) lib;
  inherit (final) resolveBuildSystem;
  addBuildSystems = pkg: spec:
    pkg.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ resolveBuildSystem spec;
    });
  # Define common build system overrides for packages
  # These are necessary because uv.lock doesn't contain build-system metadata
  buildSystemOverrides = {
    # Add custom build backend overrides
    zstd.setuptools = [];
    hdbscan.setuptools = [];
    umap.setuptools = [];
  };
in
  lib.mapAttrs (name: spec: addBuildSystems prev.${name} spec) buildSystemOverrides
  // {
    # Add specific package overrides here
    # Example for packages with C extensions or special build requirements:
    #
    # biopython = prev.biopython.overrideAttrs (attrs: {
    #   nativeBuildInputs = attrs.nativeBuildInputs or [ ] ++ [ final.setuptools ];
    #   buildInputs = attrs.buildInputs or [ ] ++ [ pkgs.zlib ];
    # });
  }
