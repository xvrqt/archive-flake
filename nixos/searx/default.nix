# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ lib, ... }:
let
  name = "searx";
  port = 3452;
  user = "crow";
  address = "127.0.0.1";
  domain = "irlqt.net";
  subDomain = "search";
in
{

  users.groups.searx.members = [ "nginx" ];
  services = {
    "${name}" = {
      enable = true;
      redisCreateLocally = true;
      settings = {
        # Instance settings
        general = {
          debug = false;
          instance_name = "xvrqt search";
          donation_url = false;
          contact_url = false;
          privacypolicy_url = false;
          enable_metrics = false;
        };

        # User interface
        ui = {
          static_use_hash = true;
          default_locale = "en";
          query_in_title = true;
          infinite_scroll = true;
          center_alignment = true;
          # TODO: Catppuccin?
          default_theme = "simple";
          theme_args.simple_style = "auto";
          search_on_category_select = true;
          hotkeys = "vim";
        };

        # Search engine settings
        search = {
          safe_search = 1;
          autocomplete_min = 2;
          autocomplete = "duckduckgo";
          ban_time_on_fail = 5;
          max_ban_time_on_fail = 120;
          formats = [ "html" "json" ];
        };

        # Server configuration
        server = {
          base_url = "https://${subDomain}.${domain}";
          port = port;
          bind_address = "127.0.0.1";
          secret_key = "gaygirls";
          limiter = false;
          public_instance = false;
          image_proxy = true;
          method = "GET";
        };

        # Search engines
        engines = lib.mapAttrsToList (name: value: { inherit name; } // value) {
          "github".disabled = false;
          "crates.io".disabled = false;
          "stackoverflow".disabled = false;
          "superuser".disabled = false;
          "brave".disabled = true;
          "qwant".disabled = true;
          "curlie".disabled = true;
          "dictzone".disabled = true;
          "lingva".disabled = true;
          "brave.images".disabled = true;
          "qwant images".disabled = true;
          "1x".disabled = true;
          "material icons".disabled = true;
          "brave.videos".disabled = true;
          "yacy images".disabled = true;
          "pinterest".disabled = true;
          "dailymotion".disabled = true;
          "brave.news".disabled = true;
          "google news".disabled = false;
          "google play movies".disabled = true;
          "invidious".disabled = false;
          "odysee".disabled = true;
          "piped".disabled = true;
          "vimeo".disabled = false;
          "duckduckgo videos".disabled = false;
          "duckduckgo images".disabled = false;
          "flickr".disabled = false;
          "currency".disabled = false;
          "duckduckgo".disabled = false;
          "mojeek".disabled = false;
          "bing".disabled = true;
          "mwmbl".disabled = false;
          "wikiquote".disabled = false;
          "wikisource".disabled = false;
          "mwmbl".weight = 0.4;
          "crowdview".disabled = false;
          "crowdview".weight = 0.5;
          "ddg definitions".disabled = false;
          "ddg definitions".weight = 2;
          "wikibooks".disabled = false;
          "wikidata".disabled = false;
          "wikispecies".disabled = false;
          "wikispecies".weight = 0.5;
          "wikiversity".disabled = false;
          "wikiversity".weight = 0.5;
          "wikivoyage".disabled = false;
          "wikivoyage".weight = 0.5;
          "bing images".disabled = false;
          "reddit".disabled = false;
          "reddit".weight = 1.5;
          "lemmyposts".disabled = false;
          "lemmyposts".weight = 1.6;
          "google images".disabled = false;
          "artic".disabled = false;
          "deviantart".disabled = false;
          "imgur".disabled = false;
          "library of congress".disabled = false;
          "material icons".weight = 0.2;
          "openverse".disabled = false;
          "svgrepo".disabled = false;
          "unsplash".disabled = false;
          "wallhaven".disabled = false;
          "wikicommons.images".disabled = false;
          "bing videos".disabled = false;
          "google videos".disabled = false;
          "qwant videos".disabled = false;
          "peertube".disabled = false;
          "rumble".disabled = false;
          "sepiasearch".disabled = false;
          "youtube".disabled = false;
        };

        # Outgoing requests
        outgoing = {
          request_timeout = 5.0;
          max_request_timeout = 15.0;
          pool_connections = 100;
          pool_maxsize = 15;
          enable_http2 = true;
        };

        # Enabled plugins
        enabled_plugins = [
          "Basic Calculator"
          "Hash plugin"
          "Tor check plugin"
          "Open Access DOI rewrite"
          "Hostnames plugin"
          "Unit converter plugin"
          "Tracker URL remover"
        ];
      };
    };

    nginx = {
      # Setup the reverse proxy
      virtualHosts."${subDomain}.${domain}" = {
        # listenAddresses = [ "10.128.0.1" ];
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          # extraConfig = ''
          #   allow 10.128.0.0/9;
          #   deny all;
          # '';
        };
      };
    };
  };
}
