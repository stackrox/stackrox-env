# Stackrox development environment

[![](http://github-actions.40ants.com/stackrox/stackrox-env/matrix.svg)](https://github.com/stackrox/stackrox-env)

Isolated and reproducible development environment for the Stackrox stack using Nix flakes.

## Environment

Compilers / runtimes:

* `golang 1.19.x`
* `openjdk 11`
* `python 3.10`

Libraries:

* `rocksdb 6.15.5`

Applications:

* `aws` and `aws-vault`
* `bats`
* Repo cleaner `bfg`
* `chamber`
* `colima` (macOS)
* `docker` (macOS)
* `gcc`
* `gcloud`
* `gradle`
* `helm`
* `jq`
* `kubectl`
* `kubectx`
* `make`
* `nodejs`
* OpenShift Client `oc`
* OpenShift Cluster Manager Client `ocm`
* `wget`
* `yarn`
* `yq`

## Prerequisites

- Install `Nix` by following the [instructions](https://nixos.org/manual/nix/stable/installation/installing-binary.html)
  based on your platform.
- **(Optional)** Clone the repository `git clone git@github.com:stackrox/stackrox-env.git ~/dev/nix/stackrox`.

## Usage

### Ad-hoc shell

Run `nix --experimental-features "nix-command flakes" develop github:stackrox/stackrox-env -c $SHELL` to open a shell
with the development environment based on the latest upstream state. Alternatively, open a shell based on a local clone
of the repository `nix --experimental-features "nix-command flakes" develop ~/dev/nix/stackrox -c $SHELL`. This allows
for more fine grained control, but requires manual updates from time to time by pulling the latest master.

### Login shell

You may choose to load the development environment inside the login shell. This effectively means that the development
environment will be available in every shell, which is convenient when no other environments are used anyway. Modifying
the login shell is recommended when working with graphical IDEs such as GoLand and VSCode.

- Clone the repository as outlined above.
- Add `source ~/dev/nix/stackrox/login.sh` to either `~/.bash_profile.sh` (bash) or `~/.zprofile` (zsh).

Note you should source `login.sh` after the lines added by the Nix installer, but before setting up the Stackrox workflow
tools (if you use them) via

```sh
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
source "$HOME/go/src/github.com/stackrox/workflow/env.sh"
```

### Direnv integration

`Direnv` allows you to automatically modify the shell environment when entering a directory. This can be used to load the
development environment upon entering the `stackrox/stackrox` repository. It is the recommended usage when working primarily
from the command line.

- Install [Direnv with Nix flake integration](https://github.com/nix-community/nix-direnv).
- Create a `.envrc` file inside the `stackrox/stackrox` directory and add `use flake github:stackrox/stackrox-env` to it.
  Alternatively, add `use flake ~/dev/nix/stackrox/` to use a local clone of the repository.

## Platforms

The Nix flake is tested via continuous integration on Linux and macOS (Intel). Unfortunately, GitHub does not provide
macOS ARM runners, but the flake should build on M1 machines as well. If not, please let me know.

## Docker on macOS

[`colima`](https://github.com/abiosoft/colima) manages a virtual machine, in which the `docker` daemon runs natively.
The `docker` context in the macOS host system is then set to the damon inside the virtual machine. This setup functions
similarly to `Docker Desktop` and may be used as a drop-in replacement.

Setup a virtual machine with 2 CPUs, 2 GiB of memory and 60 GiB of storage:

```sh
colima start --cpu 2 --memory 2 --disk 60
```

Change the resources of the virtual machine:

```sh
colima stop
colima start --cpu 4 --memory 8 --disk 60
```

Verify that the `colima` context is used by the `docker` client:
```sh
docker context list
```

Deploy a local Kubernetes cluster with access to images built or pulled with `docker`:

```sh
colima start --with-kubernetes
```

## Binary cache

To avoid long build times, all packages can be pulled from a binary cache. The `build` GitHub action builds
all packages and pushes them to the binary cache `stackrox.cachix.org`. Using the binary cache is optional.
See this [guide](https://nix.dev/faq#how-do-i-add-a-new-binary-cache) on how to enable the cache.

```
trusted-substituter: https://stackrox.cachix.org
trusted-public-key: stackrox.cachix.org-1:Wnn8TKAitOTWKfTvvHiHzJjXy0YfiwoK6rrVzXt/trA=
```

Alternativley, run

```sh
cachix use stackrox
```

which modifies the Nix system config as described above.

## Caveats

Loading the development environment inserts the `Nix` binaries at the beginning of `$PATH`.
If `$PATH` is later overwritten by another process, the isolation breaks and global version
of binaries could be first in `$PATH`.

## Contributing

### Pre-commit hook

To install the pre-commit hook, run `pre-commit install` from within the repository.
