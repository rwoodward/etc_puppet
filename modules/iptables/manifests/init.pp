# manage iptables
class iptables {
  service { "iptables":
    enable => "false",
    ensure => "stopped",
    hasstatus => "true",
  }
}
