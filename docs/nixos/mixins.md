Config extensions for a given machine.

One or more can be included per NixOS configuration.

### `nixosModules.mixins-cloud-init`

Enables [cloud-init](https://cloud-init.io)

### `nixosModules.mixins-systemd-boot`

Configure systemd-boot as bootloader.

### `nixosModules.mixins-telegraf`

Enables a generic telegraf configuration. See [Mic's dotfiles](https://github.com/Mic92/dotfiles/blob/master/nixos/eva/modules/prometheus/alert-rules.nix) for monitoring rules targeting this telegraf configuration.

### `nixosModules.nginx`

Configure Nginx with recommended settings. Is quite useful when using nginx as a reverse-proxy on the machine to other services.

### `nixosModules.mixins-trusted-nix-caches`

Add the common list of public nix binary caches that we trust.