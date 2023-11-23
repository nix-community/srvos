{ config, lib, pkgs, ... }:
let
  # Based on https://unix.stackexchange.com/questions/16578/resizable-serial-console-window
  resize = pkgs.writeShellScriptBin "resize" ''
    export PATH=${pkgs.coreutils}/bin
    if [ ! -t 0 ]; then
      # not a interactive...
      exit 0
    fi
    TTY="$(tty)"
    if [[ "$TTY" != /dev/ttyS* ]] && [[ "$TTY" != /dev/ttyAMA* ]] && [[ "$TTY" != /dev/ttySIF* ]]; then
      # probably not a known serial console, we could make this check more
      # precise by using `setserial` but this would require some additional
      # dependency
      exit 0
    fi
    old=$(stty -g)
    stty raw -echo min 0 time 5

    printf '\0337\033[r\033[999;999H\033[6n\0338' > /dev/tty
    IFS='[;R' read -r _ rows cols _ < /dev/tty

    stty "$old"
    stty cols "$cols" rows "$rows"
  '';
in
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
        <https://www.kernel.org/doc/html/v4.14/admin-guide/serial-console.html>.
      '';
    };
  };

  config = {
    boot.kernelParams = map (c: "console=${c}") config.srvos.boot.consoles;

    # set terminal size once after login
    environment.loginShellInit = "${resize}/bin/resize";

    # allows user to change terminal size when it changed locally
    environment.systemPackages = [ resize ];

    # default is something like vt220... however we want to get alt least some colors...
    systemd.services."serial-getty@".environment.TERM = "xterm-256color";

    # also make grub respond on serial consoles
    boot.loader.grub.extraConfig = ''
      serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
      terminal_input --append serial
      terminal_output --append serial
    '';
  };
}
