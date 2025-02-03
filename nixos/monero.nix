{
  pkgs,
  inputs,
  config,
  ...
}: {
environment.systemPackages = [
	pkgs.monero-cli
];
# systemd.services.xmrig.serviceConfig.DynamicUser = true;
services = {
monero = {
  enable = true;
  dataDir = "/zpools/ssd/apps/monero";
  mining = {
  	enable = true;
  address = "45XMG73AGG2L5rJq4B9HtbbhCT2ESxr2xbZdkpa8ZQ8eZGkByc4QBp8Hqfmog4LiNiTcwCphCoTfiAFq87z39Sic1oCsnCG";
  threads = 1;
  };
};
xmrig = {
  enable = false;
  settings = {
    autosave = true;
    cpu = true;
    opencl = false;
    cuda = false;
    priority = 3;
    max-threads-hint = "75%";
    pools = [
    {
            url = "107.167.83.34:9000";
            user = "45XMG73AGG2L5rJq4B9HtbbhCT2ESxr2xbZdkpa8ZQ8eZGkByc4QBp8Hqfmog4LiNiTcwCphCoTfiAFq87z39Sic1oCsnCG";
            pass = "XMRewards";
            keepalive = true;
            tls = true;
        }
    ];
  };
};
};
}
