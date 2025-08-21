# My Configurations

This repo contains all my machines' configurations. It uses [Nixverse](https://github.com/hgl/nixverse) and [nix-networkd](https://github.com/hgl/nix-networkd).

## How to bootstrap

1. Install Nix
1. Add ssh keys to `~/.ssh` so it's possible to clone the `private` submodule.

```
$ git clone --recurse-submodules git@github.com:hgl/configs.git
$ cd configs
```

After that, machines can be deployed with

```
$ nix run . node deploy routers servers
```

## Notes

`nodes/common/ssh.nix` is probably the most interesting one. It's the central place to specify the public ssh keys all machines accept and their SSH options. This demonstrates Nixverse's cross-cutting ability.
