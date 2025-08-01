# My Configurations

This repo contains all my machines' configurations. It uses [Nixverse](https://github.com/hgl/nixverse).

Each router uses [NixOS](https://github.com/hgl/nixos-router).

## How to bootstrap

`nodes/pcs/hgl` is the main machine that deploys other machines. It should be deployed before the rest can be deployed.

1. Install Nix
1. Add ssh keys to `~/.ssh` so it's possible to clone the `private` submodule.

```
$ git clone --recurse-submodules git@github.com:hgl/configs.git
$ cd configs
$ nix run . node deploy hgl
```

After that, the rest of the machines can be deployed with

```
$ nix run . node deploy routers servers
```

## Notes

`nodes/common/ssh.nix` is probably the most interesting one. It's the central place to specify the public ssh keys all machines accept and their SSH options. This demonstrates Nixverse's cross-cutting ability.
