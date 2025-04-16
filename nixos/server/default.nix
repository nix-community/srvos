# A default configuration that applies to all servers.
# Common configuration across *all* the machines
{
  config,
  lib,
  options,
  pkgs,
  ...
}:
{

  imports = [
    ../common
    ../../shared/server.nix
  ];

  # used in shared/server.nix
  programs.git.package = lib.mkDefault pkgs.gitMinimal;

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

  documentation.nixos.enable = lib.mkDefault config.srvos.server.docs.enable;

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
      runtimeTime = lib.mkDefault "15s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = lib.mkDefault "30s";
      # Forcefully reboot when a host hangs after kexec.
      # This may be the case when the firmware does not support kexec.
      kexecTime = lib.mkDefault "1m";
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };

  # Make sure the serial console is visible in qemu when testing the server configuration
  # with nixos-rebuild build-vm
  virtualisation.vmVariant.virtualisation.graphics = lib.mkDefault false;
}
