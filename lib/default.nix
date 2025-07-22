{ lib, inputs }:
{
  inherit (inputs.nixos-router-unstable.lib) addressPortString;
  concatMapCartesianProduct = f: list: lib.concatLists (map (lib.mapCartesianProduct f) list);
  imapAttrsToList = f: attrs: lib.imap0 (i: name: f i name attrs.${name}) (lib.attrNames attrs);
  concatImapAttrsToList = f: attrs: lib.concatLists (lib.imapAttrsToList f attrs);
}
