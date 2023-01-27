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
        inherit (pkgs) lib;
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

        # Dynamic files in the filesystem root of the base image
        dynamicRootFiles = pkgs.runCommandNoCC "dynamic-root-files" {} ''
          mkdir -p $out/run $out/usr/bin $out/bin $out/lib64
          ln -s ${pkgs.coreutils}/bin/env $out/usr/bin/env
          ln -s ${pkgs.bashInteractive}/bin/sh $out/bin/sh
          # So that this image can be used as a GitHub Action container directly
          # Needed because it calls its own (non-nix-patched) node binary which uses
          # this dynamic linker path. See also the LD_LIBRARY_PATH assignment below,
          # which provides the necessary libraries for that binary
          ln -s ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 $out/lib64/ld-linux-x86-64.so.2
          # Fix for go package
          ln -s ${pkgs.go_1_18}/bin/go $out/bin/go
          mkdir $out/tmp
        '';

        gha-packages = [
          pkgs.cacert
          pkgs.coreutils
          pkgs.bashInteractive
          pkgs.findutils
          pkgs.gnugrep
          pkgs.gnused
          pkgs.gitMinimal
          dynamicRootFiles
        ];

        dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = "quay.io/tjanisze/stackrox-test";
          tag = "latest";
          contents =  default-packages ++ gha-packages;
          maxLayers = 125;
          config = {
            Cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
            Env = [
              #
              "TMPDIR=/tmp"
              # Needed for git.
              "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
              # https://github.com/teamniteo/nix-docker-base/blob/fefa/image.nix#L135-L139
              # By default, the linker added in dynamicRootFiles can only find glibc
              # libraries, but the node binary from the GitHub Actions runner also
              # depends on libstdc++.so.6, which is glibc/stdenv. Using LD_LIBRARY_PATH
              # is the easiest way to inject this dependency
              "LD_LIBRARY_PATH=${lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]}"
            ];
          };
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
