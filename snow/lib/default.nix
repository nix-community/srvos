# The snow library
{
  # Classify snow.nix into a flake-compatible output.
  flake = import ./mkFlake.nix;

  # Load the snow.nix and flake.nix together for a better future.
  plow = import ./plow.nix;
}
