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
      # Ignore if the system is getting installed
      if [[ ! -e /run/current-system ]]; then
        exit
      fi

      actual=$(< /proc/sys/kernel/hostname)
      desired=${config.networking.hostName}
      if [[ "$actual" = "$desired" ]]; then
        exit
      fi

      # Useful for automation
      if [[ "''${EXPECTED_HOSTNAME:-}" = "$desired" ]];
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
      read reply
      if [[ $reply != YES ]]; then
        echo "aborting"
        exit 1
      fi
    '';
  };
}
