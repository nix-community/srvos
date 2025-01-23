# Protection against deploying system closures to the wrong host.
{
  config,
  lib,
  ...
}:
{
  options.srvos.detect-hostname-change = {
    enable = lib.mkEnableOption "warn if the hostname changes between deploys" // {
      default = true;
    };
  };

  config = lib.mkIf (config.srvos.detect-hostname-change.enable && config.networking.hostName != "") {
    system.preSwitchChecks.detectHostnameChange = ''
      actual=$(< /proc/sys/kernel/hostname)

      # Ignore if the system is getting installed
      # https://github.com/nix-community/nixos-images/blob/2fc023e024c0a5e8e98ae94363dbf2962da10886/nix/installer.nix#L12-L13
      if [[ ! -e /run/booted-system || "$actual" == "nixos-installer" ]]; then
        exit
      fi

      desired=${config.networking.hostName}

      if [[ "$actual" = "$desired" ]]; then
        exit
      fi

      # Useful for automation
      if [[ "''${EXPECTED_HOSTNAME:-}" = "$desired" ]]; then
        exit
      fi

      log() {
        echo "$*" >&2
      }

      log "WARNING: machine hostname change detected from '$actual' to '$desired'"
      log
      log "Are you deploying on the right host?"
      log
      log "Type YES to continue:"
      read -r reply
      if [[ $reply != YES ]]; then
        echo "aborting"
        exit 1
      fi
    '';
  };
}
