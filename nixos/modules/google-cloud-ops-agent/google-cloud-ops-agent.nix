{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "ops-agent";
  version = "2.67.0";
  src = fetchFromGitHub {
    owner = "GoogleCloudPlatform";
    repo = "ops-agent";
    rev = "refs/tags/${version}";
    hash = "sha256-2jBFZkmbIDvpbp2hVzwYSDzhi8feMY5n+matRLmTFgQ=";
  };
  ldFlags = [
    "-X github.com/GoogleCloudPlatform/ops-agent/internal/version.Version=${version}"
    "-X github.com/GoogleCloudPlatform/ops-agent/internal/version.BuildDistro=nixos"
  ];
  subPackages = [
    "cmd/google_cloud_ops_agent_engine"
  ];

  doCheck = false; # requires network access

  vendorHash = "sha256-dO200wFvedyrMXj7vpfXXiLEf18BB/c8a/ZMxge9p/k=";
  meta = with lib; {
    description = "Agent that gather logs and metrics from your Google Compute Engine instances and send them to Cloud Logging and Cloud Monitoring";
    homepage = "https://github.com/GoogleCloudPlatform/ops-agent";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
