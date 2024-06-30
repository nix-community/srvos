Those high-level modules are used to define the type of machine.

We expect only one of those to be imported per Darwin configuration.

### Common (`darwinModules.common`)

Use this module if you are unsure if your darwin module will be used on server or desktop.

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

### Server (`darwinModules.server`)

Use this for headless systems that are remotely managed via ssh.

- Includes everything from common
- So far nothing else, but this might change over time

### Desktop (`darwinModules.desktop`)

Despite this project being about servers, we wanted to dogfood the common module.

- Includes everything from common
- So far nothing else, but this might change over time
