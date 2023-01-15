{ config, lib, pkgs, ... }:
{

  options = {
    # FIXME: we may move this setting upstream, once we collected some
    # experience across different vendors and hardware configuration.
    # The current defaults are similar to what other linux distributions such as
    # ubuntu and alpine linux are doing.
    srvos.boot.consoles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "tty0" ] ++
        (lib.optional (pkgs.stdenv.hostPlatform.isAarch) "ttyAMA0,115200") ++
        (lib.optional (pkgs.stdenv.hostPlatform.isRiscV64) "ttySIF0,115200") ++
        [ "ttyS0,115200" ];
      example = [ "ttyS2,115200" ];
      description = lib.mdDoc ''
        The Linux kernel console option allows you to configure various devices as
        consoles. The default setting is configured to provide access to serial
        consoles, such as IPMI SOL console redirection found in BMCs or GPIO-based
        serial terminals found in embedded devices. You can specify multiple `console=`
        options on the kernel command line, which will result in output appearing on all
        of them. The last device specified will be used when opening /dev/console. This
        information can be found in the Linux documentation at
        https://www.kernel.org/doc/html/v4.14/admin-guide/serial-console.html.
      '';
    };
  };

  config = {
    boot.kernelParams = map (c: "console=${c}") config.srvos.boot.consoles;

    # also make grub respond on serial consoles
    boot.loader.grub.extraConfig = ''
      serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
      terminal_input --append serial
      terminal_output --append serial
    '';
  };
}
