let
  inherit (builtins)
    listToAttrs
    replaceStrings
    stringLength
    substring
    ;

  removeSuffix =
    # Suffix to remove if it matches
    suffix:
    # Input string
    str:
    let
      sufLen = stringLength suffix;
      sLen = stringLength str;
    in
    if sufLen <= sLen && suffix == substring (sLen - sufLen) sufLen str then
      substring 0 (sLen - sufLen) str
    else
      str;
in
# Map 1:1 between paths and modules
baseDir: paths:
let
  prefix = stringLength (toString baseDir) + 1;

  toPair = path: {
    name = replaceStrings [ "/" ] [ "-" ] (
      removeSuffix ".nix" (substring prefix 1000000 (toString path))
    );
    value = path;
  };
in
listToAttrs (map toPair paths)
