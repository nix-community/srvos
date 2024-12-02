# A default configuration that applies to all servers.
# Common configuration across *all* the machines
{
  config,
  pkgs,
  lib,
  options,
  ...
}:
{

  imports = [
    ../common
    ../../shared/server.nix
  ];

  environment = {
    # Print the URL instead on servers
    variables.BROWSER = "echo";
    # Don't install the /lib/ld-linux.so.2 and /lib64/ld-linux-x86-64.so.2
    # stubs. Server users should know what they are doing.
    stub-ld.enable = lib.mkDefault false;
  };

  # Restrict the number of boot entries to prevent full /boot partition.
  #
  # Servers don't need too many generations.
  boot.loader.grub.configurationLimit = lib.mkDefault 5;
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 5;

  documentation.nixos.enable = lib.mkDefault false;

  # No need for fonts on a server
  fonts.fontconfig.enable = lib.mkDefault false;

  programs.command-not-found.enable = lib.mkDefault false;

  # freedesktop xdg files
  xdg.autostart.enable = lib.mkDefault false;
  xdg.icons.enable = lib.mkDefault false;
  xdg.menus.enable = lib.mkDefault false;
  xdg.mime.enable = lib.mkDefault false;
  xdg.sounds.enable = lib.mkDefault false;

  programs.vim =
    {
      defaultEditor = lib.mkDefault true;
    }
    // lib.optionalAttrs (options.programs.vim ? enable) {
      enable = lib.mkDefault true;
    };

  # Make sure firewall is enabled
  networking.firewall.enable = true;

  # Delegate the hostname setting to dhcp/cloud-init by default
  networking.hostName = lib.mkOverride 1337 ""; # lower prio than lib.mkDefault

  # If the user is in @wheel they are trusted by default.
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  security.sudo.wheelNeedsPassword = false;

  # Enable SSH everywhere
  services.openssh.enable = true;

  # UTC everywhere!
  time.timeZone = lib.mkDefault "UTC";

  # No mutable users by default
  users.mutableUsers = false;

  # Given that our systems are headless, emergency mode is useless.
  # We prefer the system to attempt to continue booting so
  # that we can hopefully still access it remotely.
  boot.initrd.systemd.suppressedUnits = lib.mkIf config.systemd.enableEmergencyMode [
    "emergency.service"
    "emergency.target"
  ];

  systemd = {
    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 7.5s.
      # If the hardware watchdog does not get a signal for 15s,
      # it will forcefully reboot the system.
      runtimeTime = "15s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
      # Forcefully reboot when a host hangs after kexec.
      # This may be the case when the firmware does not support kexec.
      kexecTime = "1m";
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };

  # https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html
  # In some cases, TCP BBR can significantly increase throughput and reduce latency,
  # however this is not true in all cases, and should be used with caution
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    # "net.ipv4.tcp_congestion_control" = "cubic";

    # Increase TCP buffer sizes for increased throughput
    "net.ipv4.tcp_rmem" = "4096	1000000	16000000";
    "net.ipv4.tcp_wmem" = "4096	1000000	16000000";
    # Default kernel
    #net.ipv4.tcp_rmem = 4096       131072  6291456
    #net.ipv4.tcp_wmem = 4096       16384   4194304

    # https://github.com/torvalds/linux/blob/master/Documentation/networking/ip-sysctl.rst?plain=1#L1042
    # https://lwn.net/Articles/560082/
    "net.ipv4.tcp_notsent_lowat" = "131072";
    #net.ipv4.tcp_notsent_lowat = 4294967295

    # Enable reuse of TIME-WAIT sockets globally
    "net.ipv4.tcp_tw_reuse" = 1;
    #net.ipv4.tcp_tw_reuse=2
    "net.ipv4.tcp_timestamps" = 1;
    "net.ipv4.tcp_ecn" = 1;

    # For machines with a lot of UDP traffic increase the buffers
    "net.core.rmem_default" = 26214400;
    "net.core.rmem_max" = 26214400;
    "net.core.wmem_default" = 26214400;
    "net.core.wmem_max" = 26214400;
    #net.core.optmem_max = 20480
    #net.core.rmem_default = 212992
    #net.core.rmem_max = 212992
    #net.core.wmem_default = 212992
    #net.core.wmem_max = 212992

    # Increase ephemeral ports
    "net.ipv4.ip_local_port_range" = "1025 65535";
    #net.ipv4.ip_local_port_range ="32768 60999"

    # detect dead connections more quickly
    "net.ipv4.tcp_keepalive_intvl" = 30;
    #net.ipv4.tcp_keepalive_intvl = 75
    "net.ipv4.tcp_keepalive_probes" = 4;
    #net.ipv4.tcp_keepalive_probes = 9
    "net.ipv4.tcp_keepalive_time" = 120;
    #net.ipv4.tcp_keepalive_time = 7200
    # 30 * 4 = 120 seconds. / 60 = 2 minutes
    # default: 75 seconds * 9 = 675 seconds. /60 = 11.25 minutes
  };

  # Make sure the serial console is visible in qemu when testing the server configuration
  # with nixos-rebuild build-vm
  virtualisation.vmVariant.virtualisation.graphics = lib.mkDefault false;
}
