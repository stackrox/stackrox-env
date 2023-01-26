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
        pkgs = import nixpkgs { inherit system; };
        pkgs-rocksdb = import nixpkgs-rocksdb-6_15_5 { inherit system; };
        darwin-pkgs =
          if pkgs.stdenv.isDarwin then [
            pkgs.colima
            pkgs.docker
          ]
          else [ ];
        # Add Python packages here.
        python-packages = ps: [
          ps.python-ldap # Dependency of aws-saml.py
          ps.pyyaml
        ];
        stackrox-python = pkgs.python3.withPackages python-packages;
        default-packages = [
          # stackrox/stackrox
          pkgs-rocksdb.rocksdb
          pkgs.bats
          pkgs.gettext # Needed for `envsubst`
          pkgs.google-cloud-sdk
          pkgs.gradle
          pkgs.jdk11
          pkgs.nodejs
          pkgs.yarn

          # stackrox/acs-fleet-manager
          pkgs.aws-vault
          pkgs.awscli2
          pkgs.chamber
          pkgs.krb5 # Dependency of aws-saml.py
          pkgs.pre-commit

          # openshift
          pkgs.ocm
          pkgs.openshift

          # misc
          pkgs.bashInteractive
          pkgs.bfg-repo-cleaner
          pkgs.cachix
          pkgs.gcc
          pkgs.gnumake
          pkgs.go_1_18
          pkgs.jq
          pkgs.kubectl
          pkgs.kubectx
          pkgs.kubernetes-helm
          pkgs.wget
          pkgs.yq-go
          stackrox-python
        ];
        dockerImage = pkgs.dockerTools.buildImage {
          name = "stackrox-test";
          copyToRoot = pkgs.buildEnv {
            name = "image-root";

            paths = default-packages;
            pathsToLink = [ "/bin" ];
          };
          config = { Cmd = [ "${pkgs.bashInteractive}/bin/bash" ]; };
        };
      in
      {
        packages = {
          docker = dockerImage;
        };
        defaultPackage = dockerImage;
        devShell = pkgs.mkShell {
          buildInputs = default-packages ++ darwin-pkgs;
        };
      }
    );
}
