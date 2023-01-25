{ lib, config, ... }: {
  # See https://github.com/NixOS/nixpkgs/issues/72394#issuecomment-549110501
  config = {
    boot.initrd.services.swraid.mdadmConf = ''
      MAILADDR root
    '';
  };
}
