Hardware modules are used to configure NixOS for well known hardware.

We expect only one hardware module to be imported per NixOS configuration.

Here are some of the hardwares that are supported:

### [`nixosModules.hardware-amazon`]({{ repo_url }}/blob/main/nixos/hardware/amazon/default.nix)

Hardware configuration for <https://aws.amazon.com/ec2> instances.

The main difference here is that the default userdata service is replaced by cloud-init.

### [`nixosModules.hardware-digitalocean-droplet`]({{ repo_url }}/blob/main/nixos/hardware/digitalocean/droplet.nix)

Hardware configuration for <https://www.digitalocean.com/> instances.

Enables cloud-init but turns of non-working dhcp.

### [`nixosModules.hardware-hetzner-cloud`]({{ repo_url }}/blob/main/nixos/hardware/hetzner-cloud/default.nix)

Hardware configuration for <https://www.hetzner.com/cloud> instances.

The main difference here is that:
1. cloud-init is enabled.
2. the qemu agent is running, to allow password reset to function.

### [`nixosModules.hardware-hetzner-cloud-arm`]({{ repo_url }}/blob/main/nixos/hardware/hetzner-cloud/arm.nix)

Hardware configuration for <https://www.hetzner.com/cloud> arm instances.

The main difference from `nixosModules.hardware-hetzner-cloud` is using systemd-boot by default.

### [`nixosModules.hardware-hetzner-online-amd`]({{ repo_url }}/blob/main/nixos/hardware/hetzner-online/amd.nix)

Hardware configuration for <https://www.hetzner.com/dedicated-rootserver> bare-metal AMD servers.

Introduces some workaround for the particular IPv6 configuration that Hetzner has.

### [`nixosModules.hardware-hetzner-online-intel`]({{ repo_url }}/blob/main/nixos/hardware/hetzner-online/intel.nix)

Hardware configuration for <https://www.hetzner.com/dedicated-rootserver> bare-metal Intel servers.

Introduces some workaround for the particular IPv6 configuration that Hetzner has.

### [`nixosModules.hardware-hetzner-online-ex101`]({{ repo_url }}/blob/main/nixos/hardware/hetzner-online/ex101.nix)

Hardware configuration for <https://www.hetzner.com/de/dedicated-rootserver/ex101> bare-metal Intel Core i9-13900 servers.

Introduces some workaround for crashes under load.
