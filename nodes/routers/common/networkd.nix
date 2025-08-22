{
  inputs',
  ...
}:
{
  imports = [
    inputs'.nix-networkd.modules.nix-networkd
  ];

  networkd = {
    interfaces = {
      lan = {
        type = "bridge";
        subnetId = 0;
      };
      guest-lan = {
        type = "vlan";
        subnetId = 1;
        vlanId = 2;
        quarantine = {
          enable = true;
        };
      };
      ipsec = {
        type = "xfrm";
        subnetId = 2;
        xfrmId = 1;
      };
      guest-ipsec = {
        type = "xfrm";
        subnetId = 3;
        xfrmId = 2;
        quarantine = {
          enable = true;
        };
      };
      wan = {
        type = "wan";
        nftables.chains.filter.input.filter = ''
          tcp dport 22 accept comment "Allow SSH"
        '';
      };
    };
  };
}
