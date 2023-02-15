## Mixins

Config extensions for a given machine.

- `mixins-cloud-init` enables [cloud-init](https://cloud-init.io)
- `mixins-systemd-boot` configure systemd-boot as bootloader
- `mixins-telegraf` enables a generic telegraf configuration. See [Mic's dotfiles](https://github.com/Mic92/dotfiles/blob/master/nixos/eva/modules/prometheus/alert-rules.nix)
  for monitoring rules targeting this telegraf configuration.
- `mixins-nginx` recommended nginx settings
- `mixins-trusted-nix-caches` list of trust-worthy public binary caches
