{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    kubenix.url = "github:hall/kubenix";
    clusterLib.url = "github:LarsZauberer/nix-clusterlib";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      kubenix,
      clusterLib,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        websitePackage = pkgs.buildNpmPackage {
          pname = "wasserxr-website";
          version = "0.0.1";
          src = lib.cleanSourceWith {
            src = ./.;
            filter =
              path: type:
              let
                relativePath = lib.removePrefix "${toString ./.}/" (toString path);
                blacklist = [
                  ".github"
                  ".gitignore"
                  ".prettierrc"
                  "LICENSE"
                  "README.md"
                  "TRADEMARK.md"
                  "cluster_builds"
                  "flake.lock"
                  "logo.svg"
                  "opencode.json"
                ];
              in
              !lib.hasSuffix ".nix" relativePath
              && !lib.any (
                excluded: relativePath == excluded || lib.hasPrefix "${excluded}/" relativePath
              ) blacklist;
          };
          npmDepsHash = "sha256-ESkzHAMefspauumje+GREewCwrNfMKCP31yjpfmtIMQ=";
          nativeBuildInputs = [
            pkgs.autoPatchelfHook
            pkgs.pkg-config
          ];
          buildInputs = [
            pkgs.vips
            pkgs.stdenv.cc.cc.lib
          ];
          npmFlags = "--ignore-scripts";
          preBuild = "autoPatchelf node_modules";
          buildPhase = "npm run build";
          installPhase = "cp -r dist $out";
        };

        nginxConf = pkgs.writeText "nginx.conf" ''
          user nobody nobody;
          events {}
          http {
            include ${pkgs.nginx}/conf/mime.types;
            server {
              listen 80;
              root /srv/http;
              index index.html;
              location / {
                try_files $uri $uri/ /index.html;
              }
            }
          }
        '';
      in
      {
        packages =
          let
            kubernetes = (import ./kubernetes.nix) {
              inherit pkgs;
              lib = pkgs.lib;
              inputs = {
                inherit
                  self
                  nixpkgs
                  flake-utils
                  kubenix
                  clusterLib
                  ;
              };
            };
          in
          {
            default = self.packages.${system}.docker;
            docker = pkgs.dockerTools.streamLayeredImage {
              name = "wasserxr-website";
              # tag omitted: defaults to the image's nix store hash, so content changes produce a new tag
              contents = [
                pkgs.nginx
                pkgs.fakeNss
              ];
              extraCommands = ''
                mkdir -p var/log/nginx var/cache/nginx tmp srv/http
                cp -r ${websitePackage}/. srv/http/
              '';
              config = {
                Cmd = [
                  "${pkgs.nginx}/bin/nginx"
                  "-c"
                  "${nginxConf}"
                  "-g"
                  "daemon off;"
                ];
                ExposedPorts."80/tcp" = { };
              };
            };
            kubernetes = kubernetes.config.kubernetes.result;
            kubernetes-docker = kubernetes.config.docker.copyScript;
          };

        devShells.default = pkgs.mkShell {
          name = "devShell";

          buildInputs = [ pkgs.nodejs ];

          shellHook = "";
        };
      }
    );
}
