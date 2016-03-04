# manage curl
class curl {
  package { 'curl':
    ensure => installed,
  }
}
