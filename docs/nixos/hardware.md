Hardware modules are used to configure NixOS for well known hardware.

We expect only one hardware module to be imported per NixOS configuration.

Here are some of the hardwares that are supported:

### `nixosModules.hardware-amazon`

Hardware configuration for <https://aws.amazon.com/ec2> instances.

The main difference here is that the default userdata service is replaced by cloud-init.

### `nixosModules.hardware-digitalocean-droplet`

Hardware configuration for <https://www.digitalocean.com/> instances.

Enables cloud-init but turns of non-working dhcp.

### `nixosModules.hardware-hetzner-cloud`

Hardware configuration for <https://www.hetzner.com/cloud> instances.

The main difference here is that:
1. cloud-init is enabled.
2. the qemu agent is running, to allow password reset to function.

### `nixosModules.hardware-hetzner-cloud-arm`

Hardware configuration for <https://www.hetzner.com/cloud> arm instances.

The main difference from `nixosModules.hardware-hetzner-cloud` is using systemd-boot by default.

### `nixosModules.hardware-hetzner-online-amd`

Hardware configuration for <https://www.hetzner.com/dedicated-rootserver> bare-metal AMD servers.

Introduces some workaround for the particular IPv6 configuration that Hetzner has.

### `nixosModules.hardware-hetzner-online-intel`

Hardware configuration for <https://www.hetzner.com/dedicated-rootserver> bare-metal Intel servers.

Introduces some workaround for the particular IPv6 configuration that Hetzner has.

### `nixosModules.hardware-hetzner-online-ex101`

Hardware configuration for <https://www.hetzner.com/de/dedicated-rootserver/ex101> bare-metal Intel Core i9-13900 servers.

Introduces some workaround for crashes under load.
