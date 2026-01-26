# Better defaults for OpenSSH
{ config, lib, ... }:
{
  services.openssh = {
    settings.X11Forwarding = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PasswordAuthentication = false;
    settings.UseDns = false;
    # unbind gnupg sockets if they exists
    settings.StreamLocalBindUnlink = true;

    # Only allow system-level authorized_keys to avoid injections.
    # We currently don't enable this when git-based software that relies on this is enabled.
    # It would be nicer to make it more granular using `Match`.
    # However those match blocks cannot be put after other `extraConfig` lines
    # with the current sshd config module, which is however something the sshd
    # config parser mandates.
    authorizedKeysFiles = lib.mkIf (
      !config.services.gitea.enable
      && !config.services.gitlab.enable
      && !config.services.gitolite.enable
      && !config.services.gerrit.enable
      && !config.services.forgejo.enable
    ) (lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ]);
  };
}
