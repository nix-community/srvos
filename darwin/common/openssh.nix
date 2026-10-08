# Better defaults for OpenSSH
{
  environment.etc."ssh/sshd_config.d/102-srvos.conf".text = ''
    X11Forwarding no
    KbdInteractiveAuthentication no
    PasswordAuthentication no
    UseDns no
    # unbind gnupg sockets if they exists
    StreamLocalBindUnlink yes
  '';
}
