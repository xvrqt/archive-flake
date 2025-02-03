# Setup the NGINX Web Server & Websites hosted by this server
{
  pkgs,
  config,
  inputs,
  ...
}: let 
in {
  # Huh, this is empty now. How curious.
  # I'm sure I'll have some NGINX Global config to go here someday
  # I was 86% sure I had some already but i guesss not :\

  imports = [
    # Reverse Proxies to other services
    ./proxies.nix
    # Websites Served by NGINX
    ./websites.nix
  ];
}
