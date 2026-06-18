{ nodes, ... }: {
  x86_64-linux = {
    dnsmasq = nodes.r0.pkgs.dnsmasq;
    nftables = nodes.r0.pkgs.nftables;
    nginx = nodes.s0.config.services.nginx.package;
    strongswan = nodes.s0.config.services.strongswan-swanctl.package;
  };
  aarch64-linux = {
    codex = nodes.vm-nixos.config.home-manager.users.hgl.programs.codex.package;
    vercel = nodes.vm-nixos.pkgs'.vercel;
  };
  aarch64-darwin = {
    emacs-macport = nodes.hgl.pkgs'.emacs-macport;
    codex = nodes.hgl.config.home-manager.users.hgl.programs.codex.package;
    vercel = nodes.hgl.pkgs'.vercel;
  };
}
