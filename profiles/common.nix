# A default configuration that applies to all servers.
# Common configuration accross *all* the machines
{ config, pkgs, lib, ... }:
{
  imports = [
    ./common/upgrade-diff.nix
    ./common/well-known-hosts.nix
    ./common/zfs.nix
  ];

  # Use systemd during boot as well
  boot.initrd.systemd.enable = true;

  # Work around for https://github.com/NixOS/nixpkgs/issues/124215
  documentation.info.enable = false;

  # Allow PMTU / DHCP
  networking.firewall.allowPing = true;

  # Fallback quickly if substituters are not available.
  nix.settings.connect-timeout = 5;

  # Enable flakes
  nix.settings.experimental-features = "nix-command flakes";

  # The default at 10 is rarely enough.
  nix.settings.log-lines = lib.mkDefault 25;

  # Avoid disk full issues
  nix.settings.max-free = lib.mkDefault (1000 * 1000 * 1000);
  nix.settings.min-free = lib.mkDefault (128 * 1000 * 1000);

  # Avoid copying unnecessary stuff over SSH
  nix.settings.builders-use-substitutes = true;

  # Use the better version of nscd
  services.nscd.enableNsncd = true;

  # Allow sudo from the @wheel users
  security.sudo.enable = true;

  # Nginx sends all the access logs to /var/log/nginx/access.log by default.
  # instead of going to the journal!
  services.nginx.commonHttpConfig = ''
    access_log syslog:server=unix:/dev/log;
  '';

  # Enable SSH everywhere
  services.openssh = {
    forwardX11 = false;
    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
    useDns = false;
    # Only allow system-level authorized_keys to avoid injections.
    authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];

    # unbind gnupg sockets if they exists
    extraConfig = "StreamLocalBindUnlink yes";
  };

  systemd = {
    # Often hangs
    # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
    services = {
      NetworkManager-wait-online.enable = false;
    };
    network.wait-online.enable = false;
  };
}
