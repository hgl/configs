{
  writeShellApplication,
}:
writeShellApplication {
  name = "dnsclear";
  text = ''
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
  '';
}
