{ config, pkgs, ...}:

{
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;

  users = {
    groups.ci = {};
    users.ci = {
      isSystemUser = true;
      group = "ci";
      extraGroups = [ "wheel" ];
      home = "/home/ci";
      createHome = false;
      packages = with pkgs; [
        just
        git
      ];
      openssh.authorizedKeys.keys = [];
    };
  };
}
