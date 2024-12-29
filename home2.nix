{pkgs, ...}: let
  user = "archivist";
in {
  imports = [
  ];

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

    termusic.enable = false; # not building
    ffmpeg-full.enable = false;

    neovim.plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
  };
}

