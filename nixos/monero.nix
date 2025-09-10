{ lib, pkgs, config, inputs, machine, ... }:
let
  monero-port = 18080;
  monero-rpc-port = 18081;

  domain = "irlqt.net";
  subDomain = "archive.nodes.monero";

  addresses = inputs.networking.config.machines.${machine}.ip.v4;
  amy-net-interface = addresses.wg;
  irlqt-net-interface = addresses.tailnet;
in
{

  environment.systemPackages = [
    pkgs.monero-cli
  ];

  networking.firewall = {
    allowedTCPPorts = [ monero-port monero-rpc-port ];
  };


  # Adding --confirm-external-bind to the startup command (otherwise it won't start)
  # because we're binding to the irqt-net
  systemd.services.monero.serviceConfig.ExecStart = lib.mkForce "${lib.getExe' pkgs.monero-cli "monerod"} --config-file=${config.services.monero.dataDir}/monerod.conf --non-interactive --confirm-external-bind";

  services = {
    monero = {
      enable = true;
      # Where to store the block chain
      dataDir = "/zpools/hdd/apps/monero";

      rpc = {
        port = monero-rpc-port;
        address = irlqt-net-interface;
        restricted = false;
      };

      limits = {
        threads = 1;
        upload = 1024; # in KiB (i.e. 1 MiB total)
      };

      mining = {
        enable = true;
        threads = 1;
        address = "89BkGnoQ1T8KpzuBS2gpkoGcke9r8smfaMZzAexr1QdXT4tSecEJogXDt428qo5msCKPfHdyZASiF3QnoZmvBDXvAJPUq7o";
      };
    };
  };
}
