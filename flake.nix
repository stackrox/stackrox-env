{
  description = "Stackrox development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-go-1_17_3.url = "github:nixos/nixpkgs/5e15d5da4abb74f0dd76967044735c70e94c5af1";
    nixpkgs-rocksdb-6_15_5.url = "github:nixos/nixpkgs/a765beccb52f30a30fee313fbae483693ffe200d";
    openshift.url = "github:stehessel/oc";
    openshift.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-go-1_17_3, nixpkgs-rocksdb-6_15_5, openshift, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-go = nixpkgs-go-1_17_3.legacyPackages.${system};
        pkgs-oc = openshift.defaultPackage.${system};
        pkgs-rocksdb = nixpkgs-rocksdb-6_15_5.legacyPackages.${system};

        deps = [
          pkgs-go.go_1_17
          pkgs-rocksdb.rocksdb
          pkgs.jdk11
        ];
        deps-macos =
          if builtins.elem "${system}" pkgs.lib.platforms.darwin
          then [ pkgs.darwin.apple_sdk.frameworks.Security ]
          else [ ];
        kubernetes = [
          pkgs.kubectl
          pkgs.kubectx
          pkgs.kubernetes-helm
        ];
        ui = [
          pkgs.nodejs
          pkgs.yarn
        ];
        utils = [
          pkgs-oc
          pkgs.bats
          pkgs.gcc
          pkgs.gnumake
          pkgs.jq
          pkgs.wget
          pkgs.yq-go
        ];
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = deps ++ deps-macos ++ kubernetes ++ ui ++ utils;
        };
      }
    );
}
