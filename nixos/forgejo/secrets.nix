# Not imported, used by Agenix to encrypt secrets
let
  admin_user_key =
    (builtins.getFlake "github:xvrqt/secrets-flake").publicKeys.users.crow;
in
{
  # Archive's Wireguard private key, only accessible to itself
  "secrets/forgejo_admin_password.txt".publicKeys = [ admin_user_key ];
}
