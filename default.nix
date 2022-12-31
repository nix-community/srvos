{
  # General
  common = import ./common;
  desktop = import ./desktop.nix;
  server = import ./server.nix;

  # Mixins
  mixins-efi = import ./mixins/efi.nix;
  mixins-nginx = import ./mixins/nginx.nix;
  mixins-telegraf = import ./mixins/telegraf.nix;

  # Roles
  roles-github-actions-runner = import ./roles/github-actions-runner.nix;
}
