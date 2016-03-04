# manage rpm
class rpm {
  package { 'rpm':
    ensure => installed,
  }
}
