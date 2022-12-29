{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
    ../../mixins/cloud-init.nix
  ];

  config = {
    # Don't invoke nixos-rebuild on boot
    virtualisation.amazon-init.enable = false;

    # Use cloud-init instead
    services.cloud-init.enable = true;
  };
}
