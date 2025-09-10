# Not imported, used by Agenix to encrypt secrets
let
  crow_key =
    (builtins.getFlake "github:xvrqt/secrets-flake").publicKeys.users.crow;
in
{
  "secrets/crow_pw.txt".publicKeys = [ crow_key ];
}
