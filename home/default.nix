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
    jq = {
      colors = {
        arrays = "1;37";
        false = "0;37";
        null = "1;30";
        numbers = "0;37";
        objects = "1;37";
        strings = "0;32";
        true = "0;37";
        objectKeys = "0;37";
      };
    };
    # Enable our shell
    zsh.enable = true;
  };
}

