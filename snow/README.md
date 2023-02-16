# Snow - pack your flakes together nicely

Snow is an exploration and compatibility layer between classic nix, current
flakes, and a brighter future.

> This should be extracted into a different flake.

## How to convert a legacy package to Snow

1. Move the default.nix to snow.nix.
2. `nix flake init --template github:numtide/snow`

That's it!

## What is this black magic?

Yup.

## How to reduce the list of supported systems?

Add `nixConfig.supportedSystems = []` to the `flake.nix` file.

Eg: `nixConfig.supportedSystems = ["x86_64-linux"];`

> NOTE: we are hoping to sway upstream to make it an official part of the
>       flake metadata so it can be set on the top of the flake.
>
> Right now, there is some noise because flake asks users if the allow this
> configuration to be set.

## What does the future look like?

Like the earth, flat. I mean... We don't follow the orthodoxy.

We recognize that flakes solves fundamental problems, but it's not the
end-goal.

1. `flake.nix` will be retired and replaced by a `flake.toml`, that only
   contains project metadata.

2. No more flake eval caching. The current approach is addressing the problem
   on the wrong level. Instead:
    1. Make the Nix evaluation go faster.
    2. Remove unnecessary complexities in nixpkgs.
    3. Make the Nix evaluation resumable to allow for more fine-grained
       caching.

3. No more adding path flakes to the `/nix/store`. This fixes the following
   problems:
    1. No more `file not found` because you forgot to `git add` a file.
    2. No more adding 2GB monorepos to the /nix/store.
    3. Evaluation errors now point to the right file location.
   In order to keep the evaluation relatively pure, we propose to instead:
    1. Sandbox the Nix evaluator so that relative paths cannot reach outside
       of the flake root directory.
    2. Introduce a new type of string context for non-store paths, so that
       they explode when added to a derivation.

4. A new `flake` CLI appears. No more cramming everything into the `nix` CLI.
   Less typing.

5. `flake update nixpkgs` updates the nixpkgs input of the current flake.

6. `flake update nixpkgs --rev 325325abc4235` updates the pin of nixpkgs to
   the given revision.

7. `flake update nixpkgs --branch nixos-unstable` both updates the flake
   input, and the lockfile to use the given branch.

8. `nix develop` is scratched and replaced by `nix debug`, that actually
   drops you into the context of a build environment. We introduce `flake dev`
   as an alias to `flake run dev --`.

9. `flake run` sets the `FLAKE_ROOT` environment variable that points to the
   directory where the `flake.nix` exists before executing the program.
