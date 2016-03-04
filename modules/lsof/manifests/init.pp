# manage lsof
class lsof {
  package { 'lsof':
    ensure => installed,
  }
}
