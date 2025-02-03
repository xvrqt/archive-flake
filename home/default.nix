{ pkgs, ... }:
let
  user = "crow";
in
{
  # Home Manager Settings
  home = {
    # User Setup
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.05"; # Please read the comment before changing.
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    # Enable our shell
    zsh.enable = true;
    direnv.enable = true;
  };
}

