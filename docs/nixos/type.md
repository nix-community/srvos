Those high-level modules are used to define the type of machine.

We expect only one of those to be imported per NixOS configuration.

### Common ([`nixosModules.common`]({{ repo_url }}/blob/main/nixos/common/default.nix))

Use this module if you are unsure if your nixos module will be used on server or desktop.

- Better nix-daemon defaults
- Better serial console support
- Colored package diffs on nixos-rebuild
- Use systemd in initrd by default and networkd as a backend for the
  Networking module
- Do not block on networkd/networkmanager's online target
- Better zfs defaults
- Add ssh host keys to well-known Git servers (eg: github)
- Enable sudo for @wheel users.
- ...

### Server ([`nixosModules.server`]({{ repo_url }}/blob/main/nixos/server/default.nix))

Use this for headless systems that are remotely managed via ssh.

- Includes everything from common
- Enables OpenSSH server
- Disables desktop features like sound
- Defaults to UTC
- Configures watchdog for reboot
- Sets up sudo without password
- ...

### Desktop ([`nixosModules.desktop`]({{ repo_url }}/blob/main/nixos/desktop/default.nix))

Despite this project being about servers, we wanted to dogfood the common module.

- Includes everything from common
- Use pipewire instead of PulseAudio.
