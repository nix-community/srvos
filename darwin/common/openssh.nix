# Better defaults for OpenSSH
{ lib, ... }:
{
  environment.etc."ssh/sshd_config.d/102-srvos.conf".text = ''
    X11Forwarding no
    KbdInteractiveAuthentication no
    PasswordAuthentication no
    UseDns no
    # unbind gnupg sockets if they exists
    StreamLocalBindUnlink yes
    
    # Use key exchange algorithms recommended by `nixpkgs#ssh-audit`
    KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,sntrup761x25519-sha512@openssh.com
  '';
  # Only allow system-level authorized_keys to avoid injections.
  services.openssh.authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
}
