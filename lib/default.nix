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
  concatImap0 = f: list: lib.concatLists (lib.imap0 f list);
  concatImap0ListToAttrs =
    f: list: lib.zipAttrsWith (name: values: lib.last values) (lib.imap0 f list);
  types = {
    inherit (inputs.nix-networkd-unstable.lib.types) taggedSubmodule;
  };
}
