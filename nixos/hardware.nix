{
  config,
  pkgs,
  ...
}: let

in {
  hardware = {
    # Graphics 
    graphics = {
      enable = true;
      extraPackages = [
        pkgs.intel-compute-runtime
        pkgs.vaapiIntel
        pkgs.intel-media-driver
        pkgs.vaapiVdpau
	pkgs.intel-vaapi-driver
        pkgs.libvdpau-va-gl
      ];
    };

    nvidia = {
      nvidiaSettings = true;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = false;
    };
  };
}
