{ ... }:

{
  # Passwords are managed declaratively via files in /persist.
  # Generate with: mkpasswd -m sha-512
  users.mutableUsers = false;

  users.defaultUserHome = "/users";

  users.users.kai = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPasswordFile = "/persist/passwords/kai";
  };

  users.users.root = {
    hashedPasswordFile = "/persist/passwords/root";
  };
}
