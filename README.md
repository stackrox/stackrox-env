# Stackrox development environment

## Usage

- Install `Nix` by following the [instructions](https://nixos.org/manual/nix/stable/installation/installing-binary.html) based on your platform.
- Clone the repository `git clone git@github.com:stehessel/stackrox-env.git ~/dev/nix/stackrox`.
- Inside the repository, run `nix develop -c $SHELL` to open a shell with the development environment.

## Direnv integration

- Install [Direnv with Nix flake integration](https://github.com/nix-community/nix-direnv).
- Add `use flake ~/dev/nix/stackrox/` to the `.envrc` file inside the `stackrox/stackrox` directory.
