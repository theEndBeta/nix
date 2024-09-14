{ config, lib, pkgs, modulesPath, ... }:

{
  services.sanoid = {
    enable = true;
    interval = "hourly";

    templates.appdata = {
      hourly = 10;
      daily = 14;
      monthly = 6;
      yearly = 0;
      autosnap = true;
      autoprune = true;
    };

    datasets = {
      "tank/appdata" = {
        use_template = ["appdata"];
        processChildrenOnly = true;
      };
    };
  };
}

# vim: set expandtab ts=2 sw=2:
