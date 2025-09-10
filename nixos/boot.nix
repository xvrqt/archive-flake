{ lib
, pkgs
, ...
}:
# Boot Settings
{
  boot = {
    # Use the latest kernel
    # This is overidden by zfs.nix to ensure compatibility
    # You _did_ check that the kernel you're using is compatible with ZFS, right?
    # That could be very bad if you didn't
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    loader = {
      # Seconds until the first boot entry is selected
      # Gives me more time to react/get the screen working
      timeout = 25;

      # Allow NixOS to modify EFI variables
      efi.canTouchEfiVariables = true;

      # Gummiboot Settings
      systemd-boot = {
        enable = true;
        # Don't allow editing the kernel before booting
        editor = false;
        # Use the highest numbered available mode for the console
        consoleMode = "max";
        # Keep only the last 15 configurations
        configurationLimit = 15;
      };
    };

    # Modules the must be loaded into the Initial RAM Disk
    initrd = {
      enable = true;
      # Other modules are detected and included by './hardware-configuration.nix'
      availableKernelModules = [
        # USB Attached SCSI Protocol Enabled (higher perfomance for some USB)
        "uas"
        # SATA Block Device Support (used by ZFS for its zpools)
        "ahci"
        # NVME Block Device Support (used by ZFS Write-Ahead Device)
        "nvme"
        # SCSI Disk Support (hard drive support)
        "sd_mod"
        # USB Human Interface Device Support (we do have a physical terminal)
        "usbhid"
        # Extensible Host Controller Interface Support (USB 3.0)
        "xhci_pci"
        # USB Mass Storage Support (We mount our system disk this way)
        "usb_storage"
        # SD Card Support
        "tifm_sd"
      ];

      kernelModules = [
        # GPU Support
        "nvidia"
        # Intel CPU Temperature Monitoring
        "coretemp"
      ];
    };
  };
}
