{
  systemd.sockets.ringer = {
    enable = true;
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = 79;
      Accept = "yes";
    };
  };

  systemd.services."ringer@" = {
    enable = true;
    description = "Ringer service";
    requires = [ "ringer.socket" ];
    
    serviceConfig = {
      DynamicUser = "yes";
      ProtectHome = "true";
      ExecStart = "-${pkgs.ringer}/bin/fingerd";
      StandardInput = "socket";
      StandardOutput = "socket";
      StateDirectory = "ringer";
    };
  };
}

