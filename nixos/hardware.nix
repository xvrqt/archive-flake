{ config
, pkgs
, ...
}:
{
  hardware = {
    # Graphics 
    graphics = {
      enable = true;
      extraPackages = [
        pkgs.libvdpau-va-gl
        pkgs.intel-compute-runtime
        pkgs.vaapiIntel
        pkgs.vaapiVdpau
        pkgs.intel-media-driver
        pkgs.intel-vaapi-driver
      ];
    };

    nvidia = {
      open = false;
      nvidiaSettings = true;
      modesetting.enable = true;

      powerManagement = {
        enable = true;
        finegrained = false;
      };

      # Keep things stable since it's just a P2000 Quadro
      package = config.boot.kernelPackages.nvidiaPackages.production;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:0@2:0:0";
      };
    };
  };

  environment.systemPackages = [
    # CLI system monitoring for GPU compute
    pkgs.nvtopPackages.nvidia
    # Listing out hardware
    pkgs.lshw
  ];
}
