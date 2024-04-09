# Use pipewire instead of PulseAudio. See https://wiki.nixos.org/wiki/PipeWire
{ lib, config, ... }:
{
  security.rtkit.enable = lib.mkDefault config.services.pipewire.enable;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
  };
}
