{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  clusterLib = inputs.clusterLib.lib;
in
(inputs.kubenix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
  specialArgs = { inherit inputs; };
  module =
    {
      kubenix,
      config,
      ...
    }:
    {
      imports = [
        kubenix.modules.k8s
        kubenix.modules.helm
        kubenix.modules.docker
      ];

      config = {
        docker.images.website.image = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.docker;
        docker.registry.host = "registry.larszauberer.com";
        kubernetes.resources = lib.mkMerge [
          (clusterLib.createNamespace "wasserxr")
          (clusterLib.createDeployment {
            name = "website";
            namespace = "wasserxr";
            image = config.docker.images.website.path;
            ports = [ { port = 80; } ];
            replicas = 3;
          })
          (clusterLib.createService {
            name = "website";
            namespace = "wasserxr";
            innerPort = 80;
          })
          (clusterLib.createIngress {
            name = "website";
            namespace = "wasserxr";
            domains = [
              "wasserxr.com"
              "www.wasserxr.com"
              "wasserxr.dev"
              "www.wasserxr.dev"
              "wasserxr.org"
              "www.wasserxr.org"
              "wasserxr.ch"
              "www.wasserxr.ch"
            ];
          })
        ];
      };
    };
})
