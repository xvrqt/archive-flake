{
  services = {
    nginx = {
      # Redirect people to my ko-fi link
      # TODO move this outside my network since it has nothing to do with this machine
      virtualHosts."kofi.xvrqt.com" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        globalRedirect = "ko-fi.com/xvrqt";
      };
    };
  };
}
