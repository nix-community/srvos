{
  lib,
  ...
}:
{
  imports = [
    (lib.mkRemovedOptionModule [ "roles" "github-actions-runner" ] ''
      The github-actions-runner role was removed due to lack of maintenance.
    '')
  ];
}
