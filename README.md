# Stackrox development environment

Isolated and reproducible development environment for the Stackrox stack using Nix flakes.

## Environment

Runtimes:

* `golang 1.17.3`
* `openjdk 11`

Libraries:

* `rocksdb 6.15.5`

Applications:

* `bats`
* `gcc`
* `gnumake`
* `gradle`
* `helm`
* `jq`
* `kubectl`
* `kubectx`
* `nodejs`
* `oc`
* `wget`
* `yarn`
* `yq`

## Usage

- Install `Nix` by following the [instructions](https://nixos.org/manual/nix/stable/installation/installing-binary.html) based on your platform.
- Clone the repository `git clone git@github.com:stehessel/stackrox-env.git ~/dev/nix/stackrox`.
- Inside the repository, run `nix develop -c $SHELL` to open a shell with the development environment.

## Direnv integration

- Install [Direnv with Nix flake integration](https://github.com/nix-community/nix-direnv).
- Add `use flake ~/dev/nix/stackrox/` to the `.envrc` file inside the `stackrox/stackrox` directory.

## Platforms

The Nix flake should work (in theory) on Linux and macOS (Intel + M1). Although I have only tested on
my local machine (Intel macOS Monterey).

Nix injects a base build environment that depends on the platform (e.g. `x86_64-linux`, `x86_64-darwin`).
This means that build environments are only reproducible modulo the platform on which derivations
are evaluated. Sadly the Nix project lacks the man power to verify that all packages build successfully
on all platforms.

## Caveats

Loading the development environment inserts the `Nix` binaries at the beginning of `$PATH`.
If `$PATH` is later overwritten by another process, the isolation breaks and global version
of binaries could be first in `$PATH`.

I have not included `docker` in the build environment because at least on macOS `Docker Desktop`
is not open sourced. I'll look into replacing it with a different local Kubernetes like `minikube`
at some point.
