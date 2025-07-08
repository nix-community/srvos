{
  srvos.prometheus.ruleGroups.srvosAlerts = {
    alertRules = {
      MonitoringTooManyRestarts = {
        expr = ''changes(process_start_time_seconds{job=~"prometheus|pushgateway|alertmanager|telegraf"}[15m]) > 2'';
        annotations.description = "Service has restarted more than twice in the last 15 minutes. It might be crashlooping";
      };

      AlertManagerConfigNotSynced = {
        expr = ''count(count_values("config_hash", alertmanager_config_hash)) > 1'';
        annotations.description = "Configurations of AlertManager cluster instances are out of sync";
      };

      PrometheusNotConnectedToAlertmanager = {
        expr = "prometheus_notifications_alertmanagers_discovered < 1";
        annotations.description = "Prometheus cannot connect the alertmanager\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
      };

      PrometheusRuleEvaluationFailures = {
        expr = "increase(prometheus_rule_evaluation_failures_total[3m]) > 0";
        annotations.description = "Prometheus encountered {{ $value }} rule evaluation failures\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
      };

      PrometheusTemplateExpansionFailures = {
        expr = "increase(prometheus_template_text_expansion_failures_total[3m]) > 0";
        for = "0m";
        annotations.description = "Prometheus encountered {{ $value }} template text expansion failures\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
      };

      PromtailRequestsErrors = {
        expr = ''100 * sum(rate(promtail_request_duration_seconds_count{status_code=~"5..|failed"}[1m])) by (namespace, job, route, instance) / sum(rate(promtail_request_duration_seconds_count[1m])) by (namespace, job, route, instance) > 10'';
        for = "15m";
        annotations.description = ''{{ $labels.job }} {{ $labels.route }} is experiencing {{ printf "%.2f" $value }}% errors'';
      };

      PromtailFileLagging = {
        expr = "abs(promtail_file_bytes_total - promtail_read_bytes_total) > 1e6";
        for = "15m";
        annotations.description = "{{ $labels.instance }} {{ $labels.job }} {{ $labels.path }} has been lagging by more than 1MB for more than 15m";
      };

      Filesystem80percentFull = {
        expr = ''disk_used_percent{mode!="ro"} >= 80'';
        for = "10m";
        annotations.description = "{{$labels.instance}} device {{$labels.device}} on {{$labels.path}} got less than 20% space left on its filesystem";
      };

      FilesystemInodesFull = {
        expr = ''disk_inodes_free / disk_inodes_total < 0.10'';
        for = "10m";
        annotations.description = "{{$labels.instance}} device {{$labels.device}} on {{$labels.path}} got less than 10% inodes left on its filesystem";
      };

      # Useful for monitoring borgbackup jobs or other periodic tasks
      # https://github.com/Mic92/dotfiles/blob/922451c07d82c579b12465a9a332a559888cdc74/nixos/eve/modules/borgbackup.nix#L48
      DailyTaskNotRun = {
        expr = ''time() - task_last_run{state="ok",frequency="daily"} > (24 + 6) * 60 * 60'';
        annotations.description = "{{$labels.host}}: {{$labels.name}} was not run in the last 24h";
      };

      TenMinutesTaskNotRun = {
        expr = ''time() - task_last_run{state="ok",frequency=""} > (24 + 6) * 60 * 60'';
        annotations.description = "{{$labels.host}}: {{$labels.name}} was not run in the last 24h";
      };

      TaskFailed = {
        expr = ''task_last_run{state="fail"}'';
        annotations.description = "{{$labels.host}}: {{$labels.name}} failed to run";
      };

      # requires srvos.flake to be set so that telegraf learns about the flake inputs
      NixpkgsOutOfDate = {
        expr = ''(time() - flake_input_last_modified{input="nixpkgs"}) / (60*60*24) > 7'';
        annotations.description = "{{$labels.host}}: nixpkgs flake is older than a week";
      };

      SwapUsing30Percent = {
        expr = ''mem_swap_total - (mem_swap_cached + mem_swap_free) > mem_swap_total * 0.3'';
        for = "30m";
        annotations.description = "{{$labels.host}} is using 30% of its swap space for at least 30 minutes";
      };

      # user@$uid.service and similar sometimes fail, we don't care about those services.
      SystemdServiceFailed = {
        expr = ''systemd_units_active_code{name!~"user@\\d+.service"} == 3'';
        annotations.description = "{{$labels.host}} failed to (re)start service {{$labels.name}}";
      };

      NfsExportNotPresent = {
        expr = "nfs_export_present == 0";
        for = "1h";
        annotations.description = "{{$labels.host}} cannot reach nfs export [{{$labels.server}}]:{{$labels.path}}";
      };

      RamUsing95Percent = {
        expr = "mem_buffered + mem_free + mem_cached < mem_total * 0.05";
        for = "1h";
        annotations.description = "{{$labels.host}} is using at least 95% of its RAM for at least 1 hour";
      };

      Load15 = {
        expr = ''system_load15 / system_n_cpus >= 2.0'';
        for = "10m";
        annotations.description = "{{$labels.host}} is running with load15 > 1 for at least 5 minutes: {{$value}}";
      };

      Reboot = {
        expr = "system_uptime < 300";
        annotations.description = "{{$labels.host}} just rebooted";
      };

      Uptime = {
        expr = "system_uptime > 2592000";
        annotations.description = "{{$labels.host}} has been up for more than 30 days";
      };

      TelegrafDown = {
        expr = ''label_replace(min(up{job=~"telegraf",type!='mobile'}) by (source, job, instance, org), "host", "$1", "instance", "([^.:]+).*") == 0'';
        for = "3m";
        annotations.description = "{{$labels.instance}}: telegraf exporter from {{$labels.instance}} is down";
      };

      Ping = {
        expr = "ping_result_code{type!='mobile'} != 0";
        annotations.description = "{{$labels.url}}: ping from {{$labels.instance}} has failed";
      };

      PingHighLatency = {
        expr = "ping_average_response_ms{type!='mobile'} > 5000";
        annotations.description = "{{$labels.instance}}: ping probe from {{$labels.source}} is encountering high latency";
      };

      Http = {
        expr = "http_response_result_code != 0";
        annotations.description = "{{$labels.server}}: http request from {{$labels.instance}} has failed";
      };

      HttpMatchFailed = {
        expr = "http_response_response_string_match == 0";
        annotations.description = "{{$labels.server}}: http body not as expected; status code: {{$labels.status_code}}";
      };

      DnsQuery = {
        expr = "dns_query_result_code != 0";
        annotations.description = "{{$labels.domain}} : could retrieve A record {{$labels.instance}} from server {{$labels.server}}: {{$labels.result}}";
      };

      SecureDnsQuery = {
        expr = "secure_dns_state != 0";
        annotations.description = "{{$labels.domain}} : could retrieve A record {{$labels.instance}} from server {{$labels.server}}: {{$labels.result}} for protocol {{$labels.protocol}}";
      };

      ConnectionFailed = {
        expr = "net_response_result_code != 0";
        annotations.description = "{{$labels.server}}: connection to {{$labels.port}}({{$labels.protocol}}) failed from {{$labels.instance}}";
      };

      # https://healthchecks.io/
      Healthchecks = {
        expr = "hc_check_up == 0";
        annotations.description = "{{$labels.instance}}: healthcheck {{$labels.job}} fails";
      };

      CertExpiry = {
        expr = "x509_cert_expiry < 7*24*3600";
        annotations.description = "{{$labels.instance}}: The TLS certificate from {{$labels.source}} will expire in less than 7 days: {{$value}}s";
      };

      PostfixQueueLength = {
        expr = "avg_over_time(postfix_queue_length[1h]) > 10";
        annotations.description = "{{$labels.instance}}: postfix mail queue has undelivered {{$value}} items";
      };

      ZfsErrors = {
        expr = "zfs_arcstats_l2_io_error + zfs_dmu_tx_error + zfs_arcstats_l2_writes_error > 0";
        annotations.description = "{{$labels.instance}} reports: {{$value}} ZFS IO errors";
      };

      ZpoolErrors = {
        expr = "zpool_status_errors > 0";
        annotations.description = "{{$labels.instance}} reports: zpool {{$labels.name}} has {{$value}} errors";
      };

      MdRaidDegradedDisks = {
        expr = "mdstat_degraded_disks > 0";
        annotations.description = "{{$labels.instance}}: raid {{$labels.dev}} has failed disks";
      };

      SmartErrors = {
        expr = ''smart_device_health_ok{enabled!="Disabled"} != 1'';
        annotations.description = "{{$labels.instance}}: S.M.A.R.T reports: {{$labels.device}} ({{$labels.model}}) has errors";
      };

      OomKills = {
        expr = "increase(kernel_vmstat_oom_kill[5m]) > 0";
        annotations.description = "{{$labels.instance}}: OOM kill detected";
      };

      UnusualDiskReadLatency = {
        expr = "rate(diskio_read_time[1m]) / rate(diskio_reads[1m]) > 0.1 and rate(diskio_reads[1m]) > 0";
        annotations.description = "{{$labels.instance}}: Disk latency is growing (read operations > 100ms)";
      };

      UnusualDiskWriteLatency = {
        expr = "rate(diskio_write_time[1m]) / rate(diskio_write[1m]) > 0.1 and rate(diskio_write[1m]) > 0";
        annotations.description = "{{$labels.instance}}: Disk latency is growing (write operations > 100ms)";
      };

      Ipv6DadCheck = {
        expr = "ipv6_dad_failures_count > 0";
        annotations.description = "{{$labels.host}}: {{$value}} assigned ipv6 addresses have failed duplicate address check";
      };

      HostMemoryUnderMemoryPressure = {
        expr = "rate(kernel_vmstat_pgmajfault[1m]) > 1000";
        annotations.description = "{{$labels.instance}}: The node is under heavy memory pressure. High rate of major page faults: {{$value}}";
      };

      Ext4Errors = {
        expr = "ext4_errors_value > 0";
        annotations.description = "{{$labels.instance}}: ext4 has reported {{$value}} I/O errors: check /sys/fs/ext4/*/errors_count";
      };

      AlertmanagerSilencesChanged = {
        expr = ''abs(delta(alertmanager_silences{state="active"}[1h])) >= 1'';
        annotations.description = "alertmanager: number of active silences has changed: {{$value}}";
      };
    };
  };
}
