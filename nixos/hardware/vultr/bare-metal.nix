{ lib, inputs, modulesPath, config, ... }:
{
  imports = [
    ./.
    (modulesPath + "/profiles/all-hardware.nix")
  ];

  # This is to tell DataSourceVultr that it's really a vultr instance.
  # The DMI data is only available on the VM instances.
  #
  # DataSourceVultr.py[DEBUG]: Detecting if machine is a Vultr instance
  # dmi.py[DEBUG]: querying dmi data /sys/class/dmi/id/sys_vendor
  # dmi.py[DEBUG]: querying dmi data /sys/class/dmi/id/product_serial
  # DataSourceVultr.py[DEBUG]: Machine is a Vultr instance
  #
  # <https://github.com/canonical/cloud-init/blob/967104088db0e9724096e3776c9c31ccbb3f97cb/cloudinit/sources/helpers/vultr.py#L119-L121>
  boot.kernelParams = [ "vultr" ]; # need for cloud-init on baremetal server
}
