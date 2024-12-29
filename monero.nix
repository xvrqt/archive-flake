{
  pkgs,
  inputs,
  config,
  ...
}: {
environment.systemPackages = [
	pkgs.monero-cli
];
services = {
monero = {
  enable = true;
  dataDir = "/zpools/ssd/apps/monero";
  mining = {
	 	enable = true;
	address = "45XMG73AGG2L5rJq4B9HtbbhCT2ESxr2xbZdkpa8ZQ8eZGkByc4QBp8Hqfmog4LiNiTcwCphCoTfiAFq87z39Sic1oCsnCG";
	threads = 2;
  };
};
xmrig = {
  enable = true;
  settings = {
    autosave = true;
    cpu = true;
    opencl = false;
    cuda = false;
    pools = [
      # {
      #   url = "pool.supportxmr.com:443";
      #   user = "your-wallet";
      #   keepalive = true;
      #   tls = true;
      # }
    ];
  };
};
};
}
