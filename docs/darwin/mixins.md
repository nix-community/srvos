Config extensions for a given machine.

One or more can be included per Darwin configuration.

### [`darwinModules.mixins-telegraf`]({{ repo_url }}/blob/main/darwin/mixins/telegraf.nix)

Enables a generic telegraf configuration. `nixosModules.mixins-prometheus` for monitoring rules targeting this telegraf configuration.

### [`darwinModules.mixins-terminfo`]({{ repo_url }}/blob/main/darwin/mixins/terminfo.nix)

Extends the terminfo database with often used terminal emulators.
Terminfo is used by terminal applications to interfere supported features in the terminal.
This is useful when connecting to a server via SSH.

### [`darwinModules.mixins-nix-experimental`]({{ repo_url }}/blob/main/darwin/mixins/nix-experimental.nix)

Enables all experimental features in nix, that are known safe to use (i.e. are only used when explicitly requested in a build).

### [`darwinModules.mixins-trusted-nix-caches`]({{ repo_url }}/blob/main/darwin/mixins/trusted-nix-caches.nix)

Add the common list of public nix binary caches that we trust.

### [`darwinModules.mixins-software-update`]({{ repo_url }}/blob/main/darwin/mixins/software-update.nix)

Installs security responses and data files automatically. With `srvos.softwareUpdate.user` and `passwordFile` set, also installs and restarts into updates of the running macOS release on a schedule; Apple Silicon requires a volume owner's password for that.
