{
  description = "Stackrox development environment";

  nixConfig = {
    substituters = [
      "https://stackrox.cachix.org"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-terraform.cachix.org"
    ];
    trusted-public-keys = [
      "stackrox.cachix.org-1:Wnn8TKAitOTWKfTvvHiHzJjXy0YfiwoK6rrVzXt/trA="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      imports = [
        flake-parts.flakeModules.easyOverlay
      ];

      perSystem =
        { config
        , pkgs
        , system
        , ...
        }:
        let
          # Pinned packages.
          custom = import ./pkgs { inherit pkgs; };
          terraform = inputs.nixpkgs-terraform.packages.${system}."1.5.7";

          # Add Darwin packages here.
          darwin-pkgs =
            if pkgs.stdenv.isDarwin
            then {
              inherit
                (pkgs)
                colima
                docker
                ;
            }
            else { };

          # Add Python packages here.
          python-pkgs = ps: [
            ps.python-ldap # Dependency of aws-saml.py
            ps.pyyaml
          ];
        in
        {
          packages =
            {
              # stackrox/stackrox
              inherit
                (pkgs)
                bats
                gettext# Needed for `envsubst`
                gradle
                jdk11
                nodejs
                postgresql
                shellcheck
                yarn
                ;
              google-cloud-sdk = pkgs.google-cloud-sdk.withExtraComponents [
                pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
              ];

              # stackrox/acs-fleet-manager
              inherit
                (pkgs)
                aws-vault
                awscli2
                chamber
                krb5# Dependency of aws-saml.py
                pre-commit
                ;

              # stackrox/acs-fleet-manager-aws-config
              inherit terraform;
              inherit
                (pkgs)
                terragrunt
                detect-secrets
                ;

              # openshift
              inherit
                (pkgs)
                ocm
                openshift
                ;

              # misc
              inherit (custom) vault;
              inherit
                (pkgs)
                bfg-repo-cleaner
                bitwarden-cli
                cachix
                docker-buildx
                gcc
                gnumake
                goreleaser
                jq
                jsonnet-bundler
                k9s
                kind
                kubectl
                kubectx
                prometheus
                wget
                ;
              go = pkgs.go_1_22;
              helm = pkgs.kubernetes-helm;
              jsonnet = pkgs.go-jsonnet;
              python = pkgs.python3.withPackages python-pkgs;
              yq = pkgs.yq-go;
            }
            // darwin-pkgs;
          devShells = {
            default = pkgs.mkShell {
              buildInputs = builtins.attrValues config.packages;
            };
          };
          overlayAttrs = config.packages;
        };

      flake = {
        overlays.hashicorp = _: prev:
          withSystem prev.stdenv.hostPlatform.system (
            { config, ... }: {
              inherit
                (config.packages)
                terraform
                vault
                ;
            }
          );
      };
    });
}
