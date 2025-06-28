# My Configurations

This repo contains all my machines' configurations. It uses [Nixverse](https://github.com/hgl/nixverse).

## How to bootstrap

`nodes/pcs/hgl` is the main machine that deploys other machines. It should be deployed before the rest can be deployed.

1. Install Nix
1. Add ssh keys to `~/.ssh` so it's possible to clone the `private` submodule.

```
$ git clone --recurse-submodules git@github.com:hgl/configs.git
$ cd configs
$ darwin-rebuild switch --flake .#hgl
```

After that, the rest of the machines can be deployed with

```
$ nixos-rebuild switch --flake .#r0
$ nixverse node deploy servers
```

## Notes

`nodes/sshable` is probably the most interesting group. It demonstrates Nixverse's ability to do cross-cutting configurations. It's the central place that specifies the public ssh keys all machines accept.
