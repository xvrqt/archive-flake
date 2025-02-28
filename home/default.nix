{ ... }: {
  # Home Manager Settings
  home = {
    username = "crow";
    homeDirectory = "/home/crow";
    stateVersion = "24.05"; # Do not change!
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    # Enable our shell
    zsh.enable = true;
  };
}

