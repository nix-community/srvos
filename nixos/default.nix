let
  exposeModules = import ../lib/exposeModules.nix;
in
exposeModules ./. [
  ./common
  ./desktop
  ./hardware/amazon
  ./hardware/digitalocean/droplet.nix
  ./hardware/hetzner-cloud
  ./hardware/hetzner-cloud/arm.nix
  ./hardware/hetzner-online/amd.nix
  ./hardware/hetzner-online/arm.nix
  ./hardware/hetzner-online/intel.nix
  ./hardware/hetzner-online/ex101.nix
  ./hardware/vultr/bare-metal.nix
  ./hardware/vultr/vm.nix
  ./mixins/cloud-init.nix
  ./mixins/nginx.nix
  ./mixins/systemd-boot.nix
  ./mixins/telegraf.nix
  ./mixins/terminfo.nix
  ./mixins/tracing.nix
  ./mixins/trusted-nix-caches.nix
  ./mixins/nix-experimental.nix
  ./mixins/mdns.nix
  ./roles/github-actions-runner.nix
  ./roles/nix-remote-builder.nix
  ./roles/prometheus
  ./server
]
