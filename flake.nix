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
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-terraform, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        custom = import ./pkgs { inherit pkgs; };
        terraform = nixpkgs-terraform.packages.${system}."1.5.7";
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
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            # stackrox/stackrox
            pkgs.bats
            pkgs.gettext # Needed for `envsubst`
            (pkgs.google-cloud-sdk.withExtraComponents [ pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin ])
            pkgs.gradle
            pkgs.jdk11
            pkgs.nodejs
            pkgs.postgresql
            pkgs.yarn
            pkgs.shellcheck

            # stackrox/acs-fleet-manager
            pkgs.aws-vault
            pkgs.awscli2
            pkgs.chamber
            pkgs.krb5 # Dependency of aws-saml.py
            pkgs.pre-commit

            # stackrox/acs-fleet-manager-aws-config
            terraform
            pkgs.terragrunt
            pkgs.detect-secrets

            # openshift
            pkgs.ocm
            pkgs.openshift

            # misc
            pkgs.bfg-repo-cleaner
            pkgs.bitwarden-cli
            pkgs.cachix
            pkgs.gcc
            pkgs.gnumake
            pkgs.go_1_21
            pkgs.jq
            pkgs.jsonnet-bundler
            pkgs.go-jsonnet
            pkgs.k9s
            pkgs.kind
            pkgs.kubectl
            pkgs.kubectx
            pkgs.kubernetes-helm
            pkgs.prometheus
            custom.vault
            pkgs.wget
            pkgs.yq-go
            stackrox-python
          ] ++ darwin-pkgs;
        };
      }
    );
}
