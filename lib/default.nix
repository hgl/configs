{
  lib,
  inputs,
  ...
}:
{
  inherit (inputs.nixos-router-unstable.lib) addressPortString;
  hasAnyAttr = list: attrs: lib.any (s: lib.hasAttr s attrs) list;
}
