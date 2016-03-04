# manage openssh-server
class openssh-server {

  package { 'openssh-server':
    ensure => installed,
  }

  service { 'sshd':
    ensure => running,
    require => Package['openssh-server'],
  }
}
