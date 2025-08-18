{
  lib,
  inputs,
  ...
}:
{
  inherit (inputs.nixverse.lib) concatMapAttrsToList;
  inherit (inputs.nix-networkd-unstable.lib) decToHex;
  addressPortString =
    {
      address ? "",
      port ? null,
    }:
    "${if lib.hasInfix ":" address then "[${address}]" else address}${
      lib.optionalString (port != null) ":${toString port}"
    }";
  hasAnyAttr = list: attrs: lib.any (s: lib.hasAttr s attrs) list;
}
