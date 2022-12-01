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
    curl
    htop
    jq # needed for deploy_nixos
    termite.terminfo
  ];

  # Use vim as the default editor
  environment.variables.EDITOR = "vim";

  # Use firewalls everywhere
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

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

  # Only allow system-level authorized_keys to avoid injections.
  services.openssh.authorizedKeysFiles = lib.mkForce [
    "/etc/ssh/authorized_keys.d/%u"
  ];

  # It's okay to use unfree packages, you know?
  nixpkgs.config.allowUnfree = true;

  # Allow sudo from the @wheel users
  security.sudo.enable = true;

  # No mutable users by default
  users.mutableUsers = false;

  # Often hangs
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  systemd.services.systemd-networkd-wait-online.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
}
