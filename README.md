# Stackrox development environment

## Direnv integration

* Install [Direnv with Nix flake integration](https://github.com/nix-community/nix-direnv).
* Clone the repository `git clone git@github.com:stehessel/stackrox-env.git ~/dev/nix/stackrox`.
* Add `use flake ~/dev/nix/stackrox/` to the `.envrc` file inside the development directory.
