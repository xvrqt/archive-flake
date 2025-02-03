{pkgs, ...}:
let
  reticulum = "${pkgs.python312Packages.rns}/bin/rnsd";
in {
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
