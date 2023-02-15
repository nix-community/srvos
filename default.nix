{
  nixosModules = {
    # General
    common = import ./nixos/common;
    desktop = import ./nixos/desktop;
    server = import ./nixos/server;

    # Hardware
    hardware-amazon = import ./nixos/hardware/amazon;
    hardware-hetzner-cloud = import ./nixos/hardware/hetzner-cloud;
    hardware-hetzner-online-amd = import ./nixos/hardware/hetzner-online/amd.nix;
    hardware-hetzner-online-intel = import ./nixos/hardware/hetzner-online/intel.nix;

    # Mixins
    mixins-cloud-init = import ./nixos/mixins/cloud-init.nix;
    mixins-nginx = import ./nixos/mixins/nginx.nix;
    mixins-systemd-boot = import ./nixos/mixins/systemd-boot.nix;
    mixins-telegraf = import ./nixos/mixins/telegraf.nix;
    mixins-terminfo = import ./nixos/mixins/terminfo.nix;
    mixins-trusted-nix-caches = import ./nixos/mixins/trusted-nix-caches.nix;

    # Roles
    roles-github-actions-runner = import ./nixos/roles/github-actions-runner.nix;
    roles-nix-remote-builder = import ./nixos/roles/nix-remote-builder.nix;
  };
}
