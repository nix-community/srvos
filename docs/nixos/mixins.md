Config extensions for a given machine.

One or more can be included per NixOS configuration.

### [`nixosModules.mixins-cloud-init`]({{ repo_url }}/blob/main/nixos/mixins/cloud-init.nix)

Enables [cloud-init](https://cloud-init.io)

### [`nixosModules.mixins-systemd-boot`]({{ repo_url }}/blob/main/nixos/mixins/systemd-boot.nix)

Configure systemd-boot as bootloader.

### [`nixosModules.mixins-telegraf`]({{ repo_url }}/blob/main/nixos/mixins/telegraf.nix)

Enables a generic telegraf configuration. `nixosModules.mixins-prometheus` adds monitoring rules targeting this telegraf configuration.

### [`nixosModules.mixins-terminfo`]({{ repo_url }}/blob/main/nixos/mixins/terminfo.nix)

Extends the terminfo database with often used terminal emulators.
Terminfo is used by terminal applications to interfere supported features in the terminal.
This is useful when connecting to a server via SSH.

### [`nixosModules.mixins-prometheus`]({{ repo_url }}/blob/main/nixos/mixins/prometheus.nix)

Enables a Prometheus and configures it with a set of alert rules targeting our `nixosModules.mixins-telegraf` module.

### [`nixosModules.mixins-nginx`]({{ repo_url }}/blob/main/nixos/mixins/nginx.nix)

Configure Nginx with recommended settings. Is quite useful when using nginx as a reverse-proxy on the machine to other services.

### [`nixosModules.mixins-nix-experimental`]({{ repo_url }}/blob/main/nixos/mixins/nix-experimental.nix)

Enables all experimental features in nix, that are known safe to use (i.e. are only used when explicitly requested in a build).
This for example unlocks use of containers in the nix sandbox.

### [`nixosModules.mixins-trusted-nix-caches`]({{ repo_url }}/blob/main/nixos/mixins/trusted-nix-caches.nix)

Add the common list of public nix binary caches that we trust.

### [`nixosModules.mixins-mdns`]({{ repo_url }}/blob/main/nixos/mixins/mdns.nix)

Enables mDNS support in systemd-networkd. Becomes a no-op if avahi is enabled on the same machine.
