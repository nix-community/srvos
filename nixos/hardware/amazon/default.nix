{ modulesPath, ... }:
{

  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
    ../../mixins/cloud-init.nix
  ];

  config = {
    # Don't invoke nixos-rebuild on boot, we use cloud-init instead
    virtualisation.amazon-init.enable = false;
  };
}
