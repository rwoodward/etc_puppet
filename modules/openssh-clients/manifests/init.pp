# manage openssh-clients
class openssh-clients {
  package { 'openssh-clients':
    ensure => installed,
  }
}
