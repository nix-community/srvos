Config extensions for a given machine.

One or more can be included per NixOS configuration.

### `nixosModules.mixins-cloud-init`

Enables [cloud-init](https://cloud-init.io)

### `nixosModules.mixins-systemd-boot`

Configure systemd-boot as bootloader.

### `nixosModules.mixins-telegraf`

Enables a generic telegraf configuration. See [Mic's dotfiles](https://github.com/Mic92/dotfiles/blob/master/nixos/eva/modules/prometheus/alert-rules.nix) for monitoring rules targeting this telegraf configuration.

### `nixosModules.mixins-nginx`

Configure Nginx with recommended settings. Is quite useful when using nginx as a reverse-proxy on the machine to other services.

### `nixosModules.mixins-nix-experimental`

Enables all experimental features in nix, that are known safe to use (i.e. are only used when explicitly requested in a build).
This for example unlocks use of containers in the nix sandbox.

### `nixosModules.mixins-trusted-nix-caches`

Add the common list of public nix binary caches that we trust.
