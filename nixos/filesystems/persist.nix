# Using the Impermanence Module
# https://github.com/nix-community/impermanence
# To create a backing store, i.e. the 'persist' subvolume and to setup the
# files and directories which are persisted through reboots to it.
{ pkgs
, ...
}:
let
  # TBD
in
{
  ###################
  ## BACKING STORE ##
  ###################

  # Requires the LUKS volume to be decrypted
  # Used as the backing store for the Persistence Module
  # Sub-Volume for opting in to persisting state
  fileSystems."/persist" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=persist" ];
    neededForBoot = true;
  };

  ####################
  ## PERSISTED DATA ##
  ####################

  # TODO: Annotate _why_ these directories
  environment.persistence."/persist" = {
    directories = [
      "/key"
      "/var/apps"
      "/var/www"
      "/var/log"
      "/etc/ssh"
      "/var/lib"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/etc/nix/id_rsa"
      #"/etc/exports.d/zfs.exports"
    ];
  };
}

