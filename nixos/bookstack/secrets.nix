# Not imported, used by Agenix to encrypt secrets
let
  admin_user_key =
    (builtins.getFlake "github:xvrqt/secrets-flake").publicKeys.machines.archive;
in
{
  "secrets/appKeyFile.txt".publicKeys = [ admin_user_key ];
}
