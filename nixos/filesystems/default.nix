{ pkgs, ... }: {
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
  # 
  # Everything else is mounted to a TMPFS and destroyed on reboot.

  imports = [
    # ZFS Filesystem (The Archives)
    ./zfs.nix
    # Impermanence Subvolume & Settings
    ./persist.nix
  ];

  # For formatting FAT file systems
  environment = {
    systemPackages = [
      pkgs.exfat
      pkgs.exfatprogs
    ];
  };

  ##############
  ## SWAPFILE ##
  ##############

  # The swapfile is created at a location that is persisted to the /root BTRFS
  # subvolume. This is on a flash drive, and is not ideal. It should never be 
  # used during normal operation. It only exists if rebuilding the system 
  # requires more than 32 GiB of RAM.
  swapDevices = [
    # {
    #   size = 16 * 1024; # 16 GiB
    #   device = "/var/lib/swapfile";
    # }
  ];

  #################
  ## FILESYSTEMS ##
  #################

  # The first partion of the system device is the boot partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8F58-1460";
    fsType = "vfat";
  };

  # Mount root to a TMPFS to keep the system from acquiring state 
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "mode=755" ];
    neededForBoot = true;
  };

  # Use the key on the USB stick to unlock the rest of the system partitions
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/437d5729-f2f9-4142-ab92-4329a5559627";
      keyFile = "/dev/disk/by-uuid/1980-01-01-00-00-00-00";
      keyFileSize = 4096;
      allowDiscards = true;
    };
  };

  # Sub-Volume for NixOS configuration files
  # TODO: I Think I can remove this subvolume?
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

  # Sub-Volume for storing a user's home directory (not likely to be used much)
  # TODO: Can I remove this ? Persist inidvidually ?
  fileSystems."/home" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=home" ];
  };

  boot = {
    supportedFilesystems = [ "zfs" "btrfs" ];
    # This is a server, we don't hibernate or sleep 
    kernelParams = [ "nohibernate" ];
    # We read a key off of a USB stick to decrypt the system partitions
    kernelModules = [ "usb_storage" ];
  };
}
