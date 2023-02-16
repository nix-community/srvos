{
  description = "Pack your flakes together nicely";
  outputs = { self }: {
    lib = import ./lib;

    templates.default = ./template;
  };
}
