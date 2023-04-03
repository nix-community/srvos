{
  projectRootFile = ".git/config";
  programs.deadnix.enable = true;
  programs.deadnix.no-lambda-pattern-names = true;
  programs.nixpkgs-fmt.enable = true;
  programs.shellcheck.enable = true;
  programs.shfmt.enable = true;
}
