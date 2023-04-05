# A list of well known public keys
{
  # Avoid TOFU MITM with github by providing their public key here.
  programs.ssh.knownHosts = {
    github-ed25519.hostNames = [ "github.com" ];
    github-ed25519.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

    gitlab-ed25519.hostNames = [ "gitlab.com" ];
    gitlab-ed25519.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";

    sourcehut-ed25519.hostNames = [ "git.sr.ht" ];
    sourcehut-ed25519.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
  };
}
