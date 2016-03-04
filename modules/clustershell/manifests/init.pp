# manage clustershell
class clustershell {

  require epel

  package { 'clustershell':
    ensure => installed,
  }
}
