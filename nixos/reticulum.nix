{ pkgs, ... }:
let
  reticulum = "${pkgs.python312Packages.rns}/bin/rnsd";
in
{
  services = {
    # So I can view the status remotely
    nginx = {
      virtualHosts."meshchat.irlqt.net" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8000";
          proxyWebsockets = true;
        };
      };
    };
  };
  systemd.services.reticulum = {
    enable = true;
    description = "Reticulum Network Stack Daemon";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      Restart = "always";
      RestartSec = "3";
      User = "crow";
      ExecStart = "${reticulum} --service";
    };
    wantedBy = [ "multi-user.target" ];
  };

  environment.systemPackages = [
    pkgs.python312Packages.rns
    pkgs.python312Packages.lxmf
    pkgs.python312Packages.nomadnet
  ];
}
