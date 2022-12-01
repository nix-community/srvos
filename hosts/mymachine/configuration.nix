{ srvosModules, ... }:
{
  imports = [
    "${srvosModules}/roles/github-actions-runner.nix"
  ];

  roles.github-action-runner = {
    count = 3;

    github-token = "/run/keys/github-token";

    cachix-push.enable = true;
    cachix-push.token = "/run/keys/cachix-token";
  };
}
