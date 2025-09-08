{
  projectRootFile = ".git/config";
  programs.deadnix.enable = true;
  programs.deadnix.no-lambda-arg = true;
  programs.deadnix.no-lambda-pattern-names = true;
  programs.nixfmt.enable = true;
  programs.shellcheck.enable = true;
  programs.shfmt.enable = true;
}
