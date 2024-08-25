# A default configuration that applies to all servers.
# Common configuration across *all* the machines
{
  pkgs,
  lib,
  options,
  ...
}:
{

  imports = [ ../common ];

  environment = {
    # List packages installed in system profile.
    systemPackages = map lib.lowPrio [
      pkgs.curl
      pkgs.dnsutils
      pkgs.gitMinimal
      pkgs.htop
      pkgs.jq
      pkgs.tmux
    ];
    # Print the URL instead on servers
    variables.BROWSER = "echo";
    # Don't install the /lib/ld-linux.so.2 and /lib64/ld-linux-x86-64.so.2
    # stubs. Server users should know what they are doing.
    stub-ld.enable = lib.mkDefault false;
  };

  # Notice this also disables --help for some commands such es nixos-rebuild
  documentation.enable = lib.mkDefault false;
  documentation.info.enable = lib.mkDefault false;
  documentation.man.enable = lib.mkDefault false;
  documentation.nixos.enable = lib.mkDefault false;

  # No need for fonts on a server
  fonts.fontconfig.enable = lib.mkDefault false;

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

  systemd = {
    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 10s.
      # If the hardware watchdog does not get a signal for 20s,
      # it will forcefully reboot the system.
      runtimeTime = "20s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };

  # use TCP BBR has significantly increased throughput and reduced latency for connections
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
