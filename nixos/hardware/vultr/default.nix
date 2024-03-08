{ options, lib, ... }: {
  imports = [
    ../../mixins/cloud-init.nix
  ];

  config = {

    services.cloud-init.settings.datasource_list = [ "Vultr" ];
    services.cloud-init.settings.datasource.Vultr = { };

  } // (lib.optionalAttrs ((options.srvos.boot or { }) ? consoles) {
    # tty1 is used by all of the servers so we don't want a serial console
    srvos.boot.consoles = lib.mkDefault [ ];
  });

}
