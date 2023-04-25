{
  imports = [
    ../../mixins/cloud-init.nix
  ];

  services.cloud-init.settings.datasource_list = [ "Vultr" ];
  services.cloud-init.settings.datasource.Vultr = { };
}
