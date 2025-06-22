##############
## OVERVIEW ##
##############

# There are 2 ZFS Pools for Storage:
# - SSD (Mirrored 2 Tib)
# - HDD (Z2RAID ~48 TiB + 512 Gib NVME Write-Ahead-Journal)
# These are for storing data only, and no part of the system
# should ever make its way to these disks.

{ lib, pkgs, config, ... }:
let
  # Our two pools
  zpools = [ "SSD" "HDD" ];
  # Latest LTS Linux Kernel officially supported by OpenZFS
  kernelPkg = pkgs.linuxPackages_6_14;
  # ZFS requires us to have a unique networking host ID
  hostID = "63e25167";
in
{

  #######################
  ## ZFS Kernel Compat ##
  #######################
  boot = {
    # Just in case it's ever not included by the parent
    supportedFilesystems = [ "zfs" ];
    # Ensure the kernel we're using supports ZFS (6.12 LTS)
    kernelPackages = lib.mkForce kernelPkg;

    zfs = {
      # We are not booting from ZFS
      forceImportRoot = false;
      # Import our two pools
      extraPools = zpools;
    };
  };

  ##############
  ## SERVICES ##
  ##############

  services = {
    # Configure automatice management of the zpools
    zfs = {
      # Enable periodic trimming of zpools
      # https://openzfs.github.io/openzfs-docs/man/master/8/zpool-trim.8.html
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
        # Skip taking a snapshot if the pool is undergoing a scrub; Prefix the snapshot
        # name; Keep N snapshots, destroy oldest; Append the UTC timestamp 
        # flags = " -s -p -k --utc";
        # How many snapshots to keep
        frequent = 4;
        daily = 7;
        weekly = 4;
        monthly = 12;
      };

      # Do NOT send me an email
      zed.enableMail = false;
    };

    # Enable sharing of the zpools over NFS
    nfs.server.enable = true;
  };

  # ZFS requires us to have a unique networking host ID
  networking.hostId = hostID;
}
