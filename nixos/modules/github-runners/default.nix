{
  config,
  pkgs,
  lib,
  ...
}@args:

with lib;

let
  cfg = config.services.srvos-github-runners;
in
{
  options.services.srvos-github-runners = mkOption {
    default = { };
    type =
      with types;
      attrsOf (submodule {
        options = import ./options.nix (
          args
          // {
            # services.github-runners.${name}.name doesn't have a default; it falls back to ${name} below.
            includeNameDefault = false;
          }
        );
      });
    example = {
      runner1 = {
        enable = true;
        url = "https://github.com/owner/repo";
        name = "runner1";
        tokenFile = "/secrets/token1";
      };

      runner2 = {
        enable = true;
        url = "https://github.com/owner/repo";
        name = "runner2";
        tokenFile = "/secrets/token2";
      };
    };
    description = lib.mdDoc ''
      Multiple GitHub Runners.
    '';
  };

  config = {
    assertions =
      (mapAttrsToList (_name: c: {
        assertion = !(c.tokenFile == null && c.githubApp == null);
        message = "Missing token file or github app private key file. Specify path either for token in `tokenFile` either for github app private key File in `githubApp.privateKeyFile`";
      }) cfg)
      ++ (mapAttrsToList (name: c: {
        assertion = !(c.githubApp != null && c.tokenFile != null);
        message = "${name}:Cannot set both tokenFile and github app private key file. Specify path either for token in `tokenFile` either for github app private key File in `githubApp.privateKeyFile`";
      }) cfg);

    systemd.services = flip mapAttrs' cfg (
      n: v:
      let
        svcName = "github-runner-${n}";
      in
      nameValuePair svcName (
        import ./service.nix (
          args
          // {
            inherit svcName;
            cfg = v // {
              name = if v.name != null then v.name else n;
            };
            systemdDir = "github-runner/${n}";
          }
        )
      )
    );
  };
}
