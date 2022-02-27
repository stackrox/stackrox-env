# Stackrox development environment

[![](http://github-actions.40ants.com/stehessel/stackrox-env/matrix.svg)](https://github.com/stehessel/stackrox-env)

Isolated and reproducible development environment for the Stackrox stack using Nix flakes.

## Environment

Runtimes:

* `golang 1.17.x`
* `openjdk 11`

Libraries:

* `rocksdb 6.15.5`

Applications:

* `bats`
* `gcc`
* `gcloud`
* `gradle`
* `helm`
* `jq`
* `kubectl`
* `kubectx`
* `make`
* `nodejs`
* `openshift` / `oc`
* `wget`
* `yarn`
* `yq`

## Usage

- Install `Nix` by following the [instructions](https://nixos.org/manual/nix/stable/installation/installing-binary.html) based on your platform.
- Enable experimental features to use flakes. Add `experimental-features = nix-command flakes` to `$HOME/.config/nix/nix.conf`.
- Run `nix develop github:stehessel/stackrox-env -c $SHELL` to open a shell with the development environment.

Alernatively, clone the `stehessel/stackrox-env` repository `git clone git@github.com:stehessel/stackrox-env.git ~/dev/nix/stackrox`
and execute `nix develop ~/dev/nix/stackrox -c $SHELL`.

## Direnv integration

- Install [Direnv with Nix flake integration](https://github.com/nix-community/nix-direnv).
- Create a `.envrc` file inside the `stackrox/stackrox` directory and add `use flake github:stehessel/stackrox-env` to it.

Alernatively, clone the `stehessel/stackrox-env` repository `git clone git@github.com:stehessel/stackrox-env.git ~/dev/nix/stackrox`
and add `use flake ~/dev/nix/stackrox/` to `.envrc`.

## Platforms

The Nix flake is tested via continuous integration on Linux and macOS (Intel). Unfortunately, GitHub does not provide
macOS ARM runners, but the flake should build on M1 machines as well. If not, please let me know.

## Caveats

Loading the development environment inserts the `Nix` binaries at the beginning of `$PATH`.
If `$PATH` is later overwritten by another process, the isolation breaks and global version
of binaries could be first in `$PATH`.

I have not included `docker` in the build environment because at least on macOS `Docker Desktop`
is not open sourced.
