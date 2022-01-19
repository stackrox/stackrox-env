{
  description = "Stackrox development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-rocksdb-6_15_5.url = "github:nixos/nixpkgs/a765beccb52f30a30fee313fbae483693ffe200d";
    openshift.url = "github:stehessel/oc";
    openshift.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-rocksdb-6_15_5, openshift, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-oc = openshift.defaultPackage.${system};
        pkgs-rocksdb = nixpkgs-rocksdb-6_15_5.legacyPackages.${system};

        cli = [
          pkgs-oc
          pkgs.bats
          pkgs.gcc
          pkgs.gnumake
          pkgs.gradle
          pkgs.jq
          pkgs.kubectl
          pkgs.kubectx
          pkgs.kubernetes-helm
          pkgs.wget
          pkgs.yq-go
        ];
        deps = [
          pkgs.go_1_17
          pkgs-rocksdb.rocksdb
          pkgs.jdk11
        ];
        deps-macos =
          if builtins.elem "${system}" pkgs.lib.platforms.darwin
          then [ pkgs.darwin.apple_sdk.frameworks.Security ]
          else [ ];
        ui = [
          pkgs.nodejs
          pkgs.yarn
        ];
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = cli ++ deps ++ deps-macos ++ ui;
        };
      }
    );
}
