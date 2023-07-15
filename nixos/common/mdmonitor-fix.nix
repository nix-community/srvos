{ lib, config, ... }: {
  # See https://github.com/NixOS/nixpkgs/issues/72394#issuecomment-549110501
  config = {
    boot.swraid.mdadmConf = ''
      MAILADDR root
    '';
  };
}
