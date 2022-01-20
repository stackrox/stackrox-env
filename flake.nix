{
  description = "Stackrox development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-rocksdb-6_15_5.url = "github:nixos/nixpkgs/a765beccb52f30a30fee313fbae483693ffe200d";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-rocksdb-6_15_5, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        openshift-overlay =
          prev: final: {
            openshift = final.openshift.overrideAttrs (
              prev: {
                nativeBuildInputs = prev.nativeBuildInputs ++ [ final.ncurses ];
              }
            );
          };
        pkgs = import nixpkgs
          {
            inherit system;
            overlays =
              if builtins.elem "${system}" nixpkgs.lib.platforms.darwin
              then
                [ openshift-overlay ]
              else [ ];
          };
        pkgs-rocksdb = import nixpkgs-rocksdb-6_15_5 { inherit system; };

        common = [
          pkgs-rocksdb.rocksdb
          pkgs.bats
          pkgs.gcc
          pkgs.gnumake
          pkgs.go_1_17
          pkgs.gradle
          pkgs.jdk11
          pkgs.jq
          pkgs.kubectl
          pkgs.kubectx
          pkgs.kubernetes-helm
          pkgs.nodejs
          pkgs.openshift
          pkgs.wget
          pkgs.yarn
          pkgs.yq-go
        ];
        darwin =
          if builtins.elem "${system}" pkgs.lib.platforms.darwin
          then [ pkgs.darwin.apple_sdk.frameworks.Security ]
          else [ ];
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = common ++ darwin;
        };
      }
    );
}
