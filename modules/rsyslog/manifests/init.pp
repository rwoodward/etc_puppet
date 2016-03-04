# manage rsyslog
class rsyslog {
  service { 'rsyslog':
    enable => true,
    ensure => true,
    hasstatus => true,
  }
}
