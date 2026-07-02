{
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "google-cloud-ops-agent-opentelemetry-collector";
  version = "2.67.0";

  src = fetchurl {
    # Using pre-compiled debian package as according the the agent:
    # "Building Google's custom otelopscol binary from source is incredibly complex since it involves Git submodules that invoke the OpenTelemetry ocb builder tool internally to dynamically generate Go code before compiling"
    url = "https://packages.cloud.google.com/apt/pool/google-cloud-ops-agent-jammy-all/google-cloud-ops-agent_2.67.0~ubuntu22.04_amd64_74602eb5938d0cd2d9f9edb1044c888b.deb";
    hash = "sha256-/JZ5Lf3oS95ZGORN3j5zMz5EX4kugpBoHuCVFq3rqPY=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  unpackPhase = ''
    dpkg -x $src .
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp opt/google-cloud-ops-agent/subagents/opentelemetry-collector/otelopscol $out/bin/
  '';
}
