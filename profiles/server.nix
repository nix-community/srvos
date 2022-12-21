# A default configuration that applies to all servers.
# Common configuration accross *all* the machines
{ config, pkgs, lib, ... }:
{
  imports = [
    ./common.nix
  ];

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

  # Make sure firewall is enabled
  networking.firewall.enable = true;

  # Delegate the hostname setting to dhcp/cloud-init by default
  networking.hostName = lib.mkDefault "";

  # If the user is in @wheel they are trusted by default.
  nix.settings.trusted-users = [ "root" "@wheel" ];

  security.sudo.wheelNeedsPassword = false;

  # Enable SSH everywhere
  services.openssh.enable = true;

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
      NetworkManager-wait-online.enable = false;
    };
    network.wait-online.enable = false;

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
