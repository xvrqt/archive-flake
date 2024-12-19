{
  config,
  pkgs,
  ...
}:
# Boot Settings
{
  boot = {
    # Use the latest kernel
    kernelPackages = pkgs.linuxKernel.packages.linux_6_7;

    loader = {
      # Seconds until the first boot entry is selected
      timeout = 25;

      # Allow NixOS to modify EFI variables
      efi.canTouchEfiVariables = true;

      # Gummiboot Settings
      systemd-boot = {
        enable = true;
        # Keep only the last 100 configurations
        configurationLimit = 15;
        # Use the highest numbered available mode for the console
        consoleMode = "max";
        # Don't allow editing the kernel before booting
        editor = false;
      };
    };

    # Modules the must load during boot
    initrd = {
      enable = true;
      # Other modules are detected and included by './hardware-configuration.nix'
      kernelModules = [
        # GPU
        "nvidia"
        # Intel CPU Temperature Monitoring
        "coretemp"
      ];
    };

    # Annotate why these are important
    extraModulePackages = [
      config.boot.kernelPackages.nvidia_x11
      config.boot.kernelPackages.v4l2loopback
    ];
  };
}
