{
  config,
  pkgs,
  ...
}:
# Hardware configurations (hardware-configurations.nix is auto generated by NixOS)
{
  hardware = {
    # CPU
    cpu.intel = {
      updateMicrocode = true;
    };

    # AIO CPU Liquid Cooler Controller
    gkraken.enable = true;

    # GPU
    nvidia = {
      # Use proprietary kernel modules
      open = true;
      # Use the beta driver (increases compatibility with many packages, DE/WM)
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      # Add Nvidia's GPU configuration tool to the system
      nvidiaSettings = true;
      # Allows the kernel to use the GPU during boot, among other things
      modesetting.enable = true;
      # Save VRAM state during system suspend and hibernate operations
      powerManagement.enable = false;
      # Reduces screen tearing (4090 can easily handle extra load)
      forceFullCompositionPipeline = true;
    };

    # OpenGL
    graphics = {
      enable = true;
#      driSupport = true;
#      driSupport32Bit = true;
      setLdLibraryPath = true;
      # Should add why this is important for the GPU
      extraPackages = [
        pkgs.vaapiVdpau
        pkgs.libvdpau-va-gl
      ];
    };

    # Devices
    sensor = {
      hddtemp = {
        # Monitore HDD Temperatures
        enable = true;
        # Which drives to monitor
        drives = ["/dev/disk/nvme0" "/dev/disk/nvme1"];
        # Termperature Unit of Measurement
        unit = "C";
      };
    };

    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}