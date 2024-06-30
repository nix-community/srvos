Config extensions for a given machine.

One or more can be included per NixOS configuration.

### `nixosModules.mixins-cloud-init`

Enables [cloud-init](https://cloud-init.io)

### `nixosModules.mixins-systemd-boot`

Configure systemd-boot as bootloader.

### `nixosModules.mixins-telegraf`

Enables a generic telegraf configuration. `nixosModules.mixins-prometheus` for monitoring rules targeting this telegraf configuration.

### `nixosModules.mixins-terminfo`

Extends the terminfo database with often used terminal emulators.
Terminfo is used by terminal applications to interfere supported features in the terminal.
This is useful when connecting to a server via SSH.

### `nixosModules.mixins-prometheus`

Enables a Prometheus and configures it with a set of alert rules targeting our `nixosModules.mixins-prometheus` module.

### `nixosModules.mixins-nginx`

Configure Nginx with recommended settings. Is quite useful when using nginx as a reverse-proxy on the machine to other services.

### `nixosModules.mixins-nix-experimental`

Enables all experimental features in nix, that are known safe to use (i.e. are only used when explicitly requested in a build).
This for example unlocks use of containers in the nix sandbox.

### `nixosModules.mixins-trusted-nix-caches`

Add the common list of public nix binary caches that we trust.
