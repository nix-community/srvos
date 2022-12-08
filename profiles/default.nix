# A default configuration that applies to all servers.
# Common configuration accross *all* the machines
{ config, pkgs, lib, ... }:
{
  imports = [
    ./upgrade-diff.nix
    ./well-known-hosts.nix
  ];

  # Work around for https://github.com/NixOS/nixpkgs/issues/124215
  documentation.info.enable = false;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    pkgs.curl
    pkgs.dnsutils
    pkgs.htop
    pkgs.jq
    pkgs.termite.terminfo
    pkgs.tmux
    pkgs.vim
  ];

  programs.vim.defaultEditor = true;

  # Print the URL instead on servers
  environment.variables.BROWSER = "echo";

  # Use firewalls everywhere
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  # Delegate the hostname setting to cloud-init by default
  networking.hostName = lib.mkDefault null;

  # Fallback quickly if substituters are not available.
  nix.settings.connect-timeout = 5;

  # Enable flakes
  nix.settings.experimental-features = "nix-command flakes";

  # The default at 10 is rarely enough.
  nix.settings.log-lines = 25;

  # Avoid disk full issues
  nix.settings.max-free = 1000 * 1000 * 1000;
  nix.settings.min-free = 128 * 1000 * 1000;

  # Avoid copying unnecessary stuff over SSH
  nix.settings.builders-use-substitutes = true;

  # If the user is in @wheel they are trusted by default.
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # It's okay to use unfree packages, you know?
  nixpkgs.config.allowUnfree = true;

  # Use the better version of nscd
  services.nscd.enableNsncd = true;

  # Use cloud-init for setting the hostName in dynamic environments.
  services.cloud-init.enable = true;

  # Use systemd-networkd and let cloud-init control some of its config.
  services.cloud-init.network.enable = true;

  # Allow sudo from the @wheel users
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Nginx sends all the access logs to /var/log/nginx/access.log by default.
  # instead of going to the journal!
  services.nginx.commonHttpConfig = ''
    access_log syslog:server=unix:/dev/log;
  '';

  # Enable SSH everywhere
  services.openssh = {
    enable = true;
    forwardX11 = false;
    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
    useDns = false;
    # Only allow system-level authorized_keys to avoid injections.
    authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
  };

  # Pretty heavy dependency for a VM
  services.udisks2.enable = false;

  # No need for sound on a server
  sound.enable = false;

  # UTC everywhere!
  time.timeZone = lib.mkDefault "UTC";

  # No mutable users by default
  users.mutableUsers = false;

  systemd = {
    # Often hangs
    # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
    services = {
      systemd-networkd-wait-online.enable = false;
      NetworkManager-wait-online.enable = false;
    };

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
}
