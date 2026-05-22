{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        websitePackage = pkgs.buildNpmPackage {
          pname = "wasserxr-website";
          version = "0.0.1";
          src = ./.;
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
        packages = {
          default = self.packages.${system}.docker;
          docker = pkgs.dockerTools.buildLayeredImage {
            name = "wasserxr-website";
            tag = "latest";
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
        };

        devShells.default = pkgs.mkShell {
          name = "devShell";

          buildInputs = [ pkgs.nodejs ];

          shellHook = "";
        };
      }
    );
}
