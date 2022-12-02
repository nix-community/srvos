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

  # Use vim as the default editor
  environment.variables.EDITOR = "vim";

  # Print the URL instead on servers
  environment.variables.BROWSER = "echo";

  # Use firewalls everywhere
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  # Delegate the hostname setting to cloud-init by default
  networking.hostName = lib.mkDefault null;

  # Configure all the machines with NumTide's binary cache
  nix.settings.trusted-public-keys = [
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
  ];
  nix.settings.substituters = [
    "https://numtide.cachix.org"
  ];

  # Enable a bunch of experimental features
  nix.settings.experimental-features = "nix-command flakes";

  # Avoid copying unecessary stuff over SSH
  nix.settings.builders-use-substitutes = true;

  # If the user is in @wheel they are trusted by default.
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # It's okay to use unfree packages, you know?
  nixpkgs.config.allowUnfree = true;

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

  # Often hangs
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  systemd.services.systemd-networkd-wait-online.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
}
