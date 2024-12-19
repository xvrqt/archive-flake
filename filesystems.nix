{pkgs, config, ...}: {
  ##############
  ## OVERVIEW ##
  ##############
  # There is a boot and system disk.
  # It is an NVME drive plugged into a USB-C port.
  # This is used for booting (and therefore has the boot partition)
  #
  # This is also used to store system data across several BTRFS partitions
  # These system data partitions are encrypted with LUKS and are auto
  # decrypted at boot using a key file stored in a USB drive which is also
  # plugged into the machine.
  #
  # There are 2 ZFS Pools for Storage:
  # - SSD (Mirrored 2Tib)
  # - HDD (Z2RAID ~48TiB, 512Gib NVME Write-Ahead-Journal)
  # These are for storing data only, and no part of the system
  # should ever make its way to these disks.
  # 
  # Everything else is mounted to a TMPFS and destroyed on reboot.

  #################
  ## FILESYSTEMS ##
  #################
  
  # Mount root to a TMPFS to keep the system from acquiring state 
  fileSystems."/" = { 
    device = "none";
    fsType = "tmpfs";
    neededForBoot = true;
  };

  # The first partion of the system device is the boot partition
  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/8F58-1460";
    fsType = "vfat";
  };

  # Use the key on the USB stick to unlock the rest of the system partitions
  boot.initrd.luks.devices = {
    root = {
      device        = "/dev/disk/by-uuid/437d5729-f2f9-4142-ab92-4329a5559627";
      keyFile       = "/dev/disk/by-uuid/1980-01-01-00-00-00-00";
      keyFileSize   = 4096;
      allowDiscards = true;
    };
  };

  # Sub-Volume for NixOS configuration files
  fileSystems."/etc/nixos" = { 
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=nixos-config" ];
  };

  # Sub-Volume for Nix store and more
  fileSystems."/nix" = { 
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=nix" ];
    neededForBoot = true;
  };

  # Sub-Volume for opting in to persisting state
  fileSystems."/persist" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=persist" ];
    neededForBoot = true;
  };

  # Sub-Volume for storing a user's home directory (not likely to be used much)
  fileSystems."/home" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=home" ];
  };

  # For PhotoPrism's Meta Data
  fileSystems."/var/lib/private/photoprism" = {
  	device = "/zpools/ssd/apps/photoprism";
	options = [ "bind" ];
  };
  fileSystems."/var/lib/private/photoprism/originals" = {
  	device = "/zpools/hdd/media/images";
	options = [ "bind" ];
  };
  fileSystems."/var/lib/private/photoprism/import" = {
  	device = "/zpools/ssd/xvrqt/Images";
	options = [ "bind" ];
  };

  #######################
  ## ZFS Kernel Compat ##
  #######################
  boot = {
    # Duh
    supportedFilesystems = [ "zfs" ];
    # Ensure the kernel we're using supports ZFS
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    # ZFS doesn't support swapfiles (and we are never sleeping anyways)
    kernelParams = [ "nohibernate" ];
    # We need to read a key off of a USB stick to decrypt the system partitions
    kernelModules = [ "usb_storage" ];
    
    zfs = {
      # We are not booting from ZFS
      forceImportRoot = false;
      # Import our two pools
      extraPools = [ "SSD" "HDD" ];
    };
  };
  # ZFS requires us to have a unique networking host ID
  networking.hostId = "63e25167";
  # We're not swapping
  swapDevices = [ ];

  ##############
  ## SERVICES ##
  ##############
  
  services = {
    # Configure automatice management of the zpools
    zfs = {
      # Enable periodic trimming of zpools
      trim = {
        enable = true;
	interval = "daily";
      };

      # Scrub the disk on Sunday night
      autoScrub = {
        enable = true;
	interval = "Mon, 02:00";
	pools = [ "SSD" "HDD" ];
      };

      # Auto snapshot our volumes
      autoSnapshot = {
        enable = true;
	# Skip taking a snapshot if the pool is undergoing a scrub; Prefix the snapshot name; Keep N snapshots, destroy oldest; Append the UTC timestamp 
	flags = " -s -p -k --utc";
	# How many snapshots to keep
	frequent = 4;
	daily = 7;
	weekly = 4;
	monthly = 12;
      };

      # Do NOT send me an email
      zed.enableMail = false;
    };

    # Enable sharing of the zpools
    nfs.server.enable = true;
  };
}
