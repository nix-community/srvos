{ lib, ... }: {
  # See https://github.com/NixOS/nixpkgs/issues/72394#issuecomment-549110501
  config =
    if lib.versionAtLeast (lib.versions.majorMinor lib.version) "23.11" then {
      boot.swraid.mdadmConf = "MAILADDR root";
    } else {
      boot.initrd.services.swraid.mdadmConf = "MAILADDR root";
    };
}
