{ lib }:
{
  concatMapCartesianProduct = f: list: lib.concatLists (map (lib.mapCartesianProduct f) list);
}
