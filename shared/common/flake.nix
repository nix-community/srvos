{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.srvos;

  # Safely extract source metadata from a flake input.
  # Some inputs (e.g. mics-skills) use `throw` for removed attributes,
  # so we must not iterate over all attributes or call `builtins.typeOf`
  # on the full input. Only extract known-safe attributes, and only those
  # that actually exist on the input.
  safeInputs = inputs:
    lib.mapAttrs
      (name: input:
        let
          safeAttrs = [
            "lastModified"
            "lastModifiedDate"
            "narHash"
            "outPath"
            "rev"
            "shortRev"
            "dirtyRev"
            "dirtyShortRev"
            "sourceInfo"
          ];
        in
        lib.listToAttrs (
          builtins.filter
            (a: lib.hasAttr a.name input)
            (builtins.map (a: { name = a; value = input.${a}; }) safeAttrs)
        )
      )
      inputs;

  normalizeRevision = input:
    if (!input ? rev) && (input ? dirtyRev) then
      input
      // {
        rev = input.dirtyRev;
        shortRev = input.dirtyShortRev;
      }
    else
      input;

in
{
  options.srvos = {
    flake = lib.mkOption {
      # FIXME what is the type of a flake?
      type = lib.types.nullOr lib.types.raw;
      default = null;
      description = ''
        Flake that contains the nixos configuration.
      '';
    };

    registerSelf = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Add the flake the system was built with to `nix.registry` as `self`.
        Having access to the flake the system was installed with can be useful for introspection.

        i.e. Get a development environment for the currently running kernel

        ```
        $ nix develop self#nixosConfigurations.turingmachine.config.boot.kernelPackages.kernel
        $ tar -xvf $src
        $ cd linux-*
        $ zcat /proc/config.gz  > .config
        $ make scripts prepare modules_prepare
        $ make -C . M=drivers/block/null_blk
        ```

        Set this option to false if you want to avoid uploading your configuration to every machine (i.e. in large monorepos)
      '';
    };

  };
  config = lib.mkIf (cfg.flake != null) {
    nix.registry = lib.optionalAttrs cfg.registerSelf {
      self.to = lib.mkDefault {
        type = "path";
        path = cfg.flake;
      };
    };

    services.telegraf.extraConfig.inputs.file =
      let
        # Use safeInputs to avoid calling builtins.typeOf on inputs that
        # may throw for certain attributes (e.g. mics-skills.homeManagerModules).
        safeFlakeInputs = safeInputs (cfg.flake.inputs // { inherit (cfg) flake; });

        inputsWithDate = lib.filterAttrs (_: input: input ? lastModified) safeFlakeInputs;

        flakeAttrs =
          input:
          (lib.mapAttrsToList (n: v: ''${n}="${v}"'') (
            lib.filterAttrs (_: v: (builtins.typeOf v) == "string") (normalizeRevision input)
          ));

        lastModified =
          name: input:
          ''flake_input_last_modified{input="${name}",${lib.concatStringsSep "," (flakeAttrs input)}} ${toString input.lastModified}'';

        # avoid adding store path references on flakes which me not need at runtime.
        promText = builtins.unsafeDiscardStringContext ''
          # HELP flake_registry_last_modified Last modification date of flake input in unixtime
          # TYPE flake_input_last_modified gauge
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList lastModified inputsWithDate)}
        '';
      in
      [
        {
          data_format = "prometheus";
          files = [ (pkgs.writeText "flake-inputs.prom" promText) ];
        }
      ];
  };
}
