{ lib, pkgs, config, ... }:
let
  filterEnabled = lib.filterAttrs (_: v: v.enable);
  rules.groups = lib.mapAttrsToList
    (name: group: {
      inherit name;
      rules =
        (lib.mapAttrsToList
          (name: rule: {
            alert = rule.name;
            expr = rule.expr;
            for = rule.for;
            labels = rule.labels;
            annotations = rule.annotations;
          })
          (filterEnabled group.alertRules)) ++
        (lib.mapAttrsToList
          (name: rule: {
            record = rule.name;
            expr = rule.expr;
            labels = rule.labels;
            annotations = rule.annotations;
          })
          (filterEnabled group.recordingRules));
    })
    config.srvos.prometheus.ruleGroups;
in
{
  imports = [
    ./default-alerts.nix
  ];
  options = {
    # XXX maybe we move this upstream eventually to nixpkgs. Expect this interface to be replaced with the upstream equivalent.
    srvos.prometheus.ruleGroups = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            default = name;
          };
          enable = lib.mkEnableOption (lib.mdDoc "Enable rule group") // {
            default = true;
          };
          alertRules = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  default = name;
                };
                enable = lib.mkEnableOption (lib.mdDoc "Enable alert rule") // {
                  default = true;
                };
                expr = lib.mkOption {
                  type = lib.types.str;
                };
                for = lib.mkOption {
                  type = lib.types.str;
                  default = "2m";
                };
                labels = lib.mkOption {
                  type = lib.types.attrsOf lib.types.str;
                  default = { };
                };
                annotations = lib.mkOption {
                  type = lib.types.attrsOf lib.types.str;
                  default = { };
                };
              };
            }));
            default = { };
          };
          recordingRules = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  default = name;
                };
                enable = lib.mkEnableOption (lib.mdDoc "Enable recording rule") // {
                  default = true;
                };
                expr = lib.mkOption {
                  type = lib.types.str;
                };
                for = lib.mkOption {
                  type = lib.types.str;
                  default = "2m";
                };
                labels = lib.mkOption {
                  type = lib.types.attrsOf lib.types.str;
                  default = { };
                };
                annotations = lib.mkOption {
                  type = lib.types.attrsOf lib.types.str;
                  default = { };
                };
              };
            }));
            default = { };
          };
        };
      }));
      example = {
        prometheusAlerts = {
          alertRules = {
            ExampleAlert = {
              expr = "up == 0";
              for = "4m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "Instance {{ $labels.instance }} down";
                description = "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 2 minutes.";
              };
            };
          };
          recordingRules = {
            RabbitmqDeliveredMessages = {
              expr = "rate(rabbitmq_queue_messages_delivered_total[5m])";
              annotations = {
                description = "The rate of messages delivered to queues over the last 5 minutes";
              };
            };
          };
        };
      };
    };
  };
  config = {
    services.prometheus = {
      enable = lib.mkDefault true;
      # checks fail because of missing secrets in the sandbox
      checkConfig = "syntax-only";
      ruleFiles = [ (pkgs.writers.writeYAML "rules.yaml" rules) ];
    };
  };
}
