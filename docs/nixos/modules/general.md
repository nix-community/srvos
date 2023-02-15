## General

Used to define the type of machine.

- `server`:
  - Use this for headless systems that are remotely managed via ssh
  - Includes everything from common
  - Disables desktop features like sound
  - Defaults to UTC
  - Enables ssh
  - Configures watchdog for reboot
  - Sets up sudo without password
  - ...
- `desktop`:
  - Mostly based on common but also includes some optimization for useful for interactive usage
- `common`:
  - Use if you are unsure if your nixos module will be used on server or desktop
  - Better nix-daemon defaults
  - Better serial console support
  - Colored package diffs on nixos-rebuild
  - Use systemd in initrd by default and networkd as a backend for the
    Networking module
  - Do not block on networkd/networkmanager's online target
  - Better zfs defaults
  - Add well-known ssh git ssh keys to the git configuration