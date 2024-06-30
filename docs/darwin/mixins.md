Config extensions for a given machine.

One or more can be included per Darwin configuration.

### `darwiModules.mixins-telegraf`

Enables a generic telegraf configuration. `nixosModules.mixins-prometheus` for monitoring rules targeting this telegraf configuration.

### `darwinModules.mixins-terminfo`

Extends the terminfo database with often used terminal emulators.
Terminfo is used by terminal applications to interfere supported features in the terminal.
This is useful when connecting to a server via SSH.
