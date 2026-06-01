{
  config,
  lib,
  pkgs,
  ...
}:
let
  google-cloud-ops-agent = pkgs.callPackage ./google-cloud-ops-agent.nix { };
  google-cloud-ops-agent-opentelemetry-collector =
    pkgs.callPackage ./google-cloud-ops-agent-opentelemetry-collector.nix
      { };
  settingsFormat = pkgs.formats.json { };
  cfg = config.services.google-cloud-ops-agent;
  configFile = settingsFormat.generate "config.yaml" cfg.settings;
in
{
  options = {
    services.google-cloud-ops-agent.enable = lib.mkEnableOption "Google Cloud Ops Agent";
    services.google-cloud-ops-agent.settings = lib.mkOption rec {
      type = settingsFormat.type;
      default = { };
      description = lib.mdDoc ''
        Configuration for Google Cloud Ops Agent. See
        https://cloud.google.com/monitoring/agent/monitoring/configuration
        for supported values.
      '';
    };
  };
  config = lib.mkIf config.services.google-cloud-ops-agent.enable {
    users.users.google-cloud-ops-agent = {
      isSystemUser = true;
      group = "google-cloud-ops-agent";
      description = "Google Cloud Ops Agent user";
      extraGroups = [ "systemd-journal" ]; # Needed to read systemd logs
    };

    users.groups.google-cloud-ops-agent = { };

    systemd.services.google-cloud-ops-agent-fluent-bit = {
      description = "Google Cloud Ops Agent - Fluent Bit";
      wantedBy = [ "multi-user.target" ];
      partOf = [ "google-cloud-ops-agent.service" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        User = "google-cloud-ops-agent";
        Group = "google-cloud-ops-agent";
        RuntimeDirectory = "google-cloud-ops-agent-fluent-bit";
        StateDirectory = "google-cloud-ops-agent/fluent-bit";
        LogsDirectory = "google-cloud-ops-agent/subagents";
        Type = "simple";
        ExecStartPre = "+${google-cloud-ops-agent}/bin/google_cloud_ops_agent_engine -service=fluentbit -in ${configFile} -logs \${LOGS_DIRECTORY} -state \${STATE_DIRECTORY}";
        ExecStart = "${pkgs.fluent-bit}/bin/fluent-bit --config \${RUNTIME_DIRECTORY}/fluent_bit_main.conf --parser \${RUNTIME_DIRECTORY}/fluent_bit_parser.conf --log_file \${LOGS_DIRECTORY}/logging-module.log --storage_path \${STATE_DIRECTORY}/buffers";
        Restart = "always";
        RestartSec = "10s";
        # For debugging:
        RuntimeDirectoryPreserve = "yes";
        # Security hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
      };
    };

    systemd.services.google-cloud-ops-agent-opentelemetry-collector = {
      description = "Google Cloud Ops Agent - Metrics Agent";
      wantedBy = [ "multi-user.target" ];
      partOf = [ "google-cloud-ops-agent.service" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        User = "google-cloud-ops-agent";
        Group = "google-cloud-ops-agent";
        RuntimeDirectory = "google-cloud-ops-agent-opentelemetry-collector";
        StateDirectory = "google-cloud-ops-agent/opentelemetry-collector";
        LogsDirectory = "google-cloud-ops-agent";
        Type = "simple";
        ExecStartPre = "+${google-cloud-ops-agent}/bin/google_cloud_ops_agent_engine -service=otel -in ${configFile} -logs \${LOGS_DIRECTORY} -state \${STATE_DIRECTORY}";
        ExecStart = "${google-cloud-ops-agent-opentelemetry-collector}/bin/otelopscol --config \${RUNTIME_DIRECTORY}/otel.yaml";
        Restart = "always";
        RestartSec = "10s";
        # For debugging:
        RuntimeDirectoryPreserve = "yes";
        # Security hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        # Capabilities needed for reading process and system metrics
        AmbientCapabilities = "CAP_SYS_PTRACE";
      };
    };

    systemd.services.google-cloud-ops-agent = {
      description = "Google Cloud Ops Agent";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [
        "network-online.target"
        "google-cloud-ops-agent-opentelemetry-collector.service"
        "google-cloud-ops-agent-fluent-bit.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStartPre = "${google-cloud-ops-agent}/bin/google_cloud_ops_agent_engine -in ${configFile}";
        ExecStart = "${pkgs.coreutils}/bin/true";
        RemainAfterExit = "yes";
      };
    };
  };
}
