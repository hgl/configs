{
  pkgs,
  modulesPath,
  config,
  nodes,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  boot = {
    initrd.includeDefaultModules = false;
    loader = {
      timeout = 0;
      grub = {
        enable = true;
        device = nodes.current.install.partitions.device;
      };
    };
  };

  nix = {
    optimise.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  time.timeZone = "Asia/Shanghai";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.mutableUsers = false;
  users.users.root = {
    shell = pkgs.fish;
  };
  programs.fish = {
    enable = true;
  };
  environment.shells = with pkgs; [
    fish
  ];

  networking = {
    useDHCP = false;
    firewall.enable = false;
  };

  systemd.network = {
    enable = true;
    networks."99-default" = {
      matchConfig = {
        Name = "*";
      };
      networkConfig = {
        DHCP = true;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      webroot = "/var/lib/acme/acme-challenge";
    };
  };

  services.caddy = {
    enable = true;
    globalConfig = ''
      auto_https off
    '';
    virtualHosts = {
      acme = {
        hostName = "http://";
        logFormat = ''
          output file ${config.services.caddy.logDir}/access-http.log
        '';
        extraConfig = ''
          header -Server
          handle /.well-known/acme-challenge/* {
            file_server {
              root ${config.security.acme.defaults.webroot}
            }
          }
          handle {
            redir https://{host}{uri} 301
          }
        '';
      };
      ${config.networking.fqdn} = {
        useACMEHost = config.networking.fqdn;
        serverAliases = [ "https://" ];
        logFormat = ''
          output file ${config.services.caddy.logDir}/access-${config.networking.fqdn}.log
        '';
        extraConfig = ''
          header {
            -Server
            Strict-Transport-Security max-age=63072000
          }
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    dig
    tcpdump
    btop
    iperf
    rsync
  ];

  system.stateVersion = "24.05";
}
