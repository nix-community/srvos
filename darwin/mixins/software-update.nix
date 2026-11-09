{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.srvos.softwareUpdate;
  script = pkgs.writeShellScript "srvos-software-update" ''
    set -euo pipefail
    major=$(/usr/bin/sw_vers -productVersion | cut -d. -f1)
    labels=()
    while IFS= read -r label; do
      if [[ $label =~ ^macOS\ (.*\ )?([0-9]+)\.[0-9.]*- && ''${BASH_REMATCH[2]} != "$major" ]]; then
        continue
      fi
      labels+=("$label")
    done < <(/usr/sbin/softwareupdate --list 2>/dev/null | sed -n 's/^\* Label: //p')
    if [[ ''${#labels[@]} -eq 0 ]]; then
      echo "no updates"
      exit 0
    fi
    echo "installing: ''${labels[*]}"
    /usr/sbin/softwareupdate --install --restart --agree-to-license \
      --user ${lib.escapeShellArg cfg.user} --stdinpass "''${labels[@]}" \
      < ${lib.escapeShellArg cfg.passwordFile}
  '';
in
{
  options.srvos.softwareUpdate = {
    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Volume owner (see `diskutil apfs listUsers /`) whose password
        authorizes installing updates. Apple Silicon Macs install OS updates
        only with it. If null, only security responses and data files are
        installed automatically.
      '';
    };
    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "File with the password of `user`, readable by root only.";
    };
    schedule = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.int);
      default = [
        {
          Weekday = 0;
          Hour = 4;
          Minute = 0;
        }
      ];
      description = "launchd StartCalendarInterval for installing updates and restarting.";
    };
  };

  config = lib.mkMerge [
    {
      system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      system.defaults.CustomSystemPreferences."/Library/Preferences/com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        AutomaticDownload = true;
        CriticalUpdateInstall = true;
        ConfigDataInstall = true;
      };
    }
    (lib.mkIf (cfg.user != null) {
      assertions = [
        {
          assertion = cfg.passwordFile != null;
          message = "srvos.softwareUpdate.passwordFile must be set together with user";
        }
      ];
      launchd.daemons.srvos-software-update.serviceConfig = {
        ProgramArguments = [ "${script}" ];
        StartCalendarInterval = cfg.schedule;
        StandardOutPath = "/var/log/srvos-software-update.log";
        StandardErrorPath = "/var/log/srvos-software-update.log";
      };
    })
  ];
}
