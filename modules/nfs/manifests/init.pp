# manage nfs
class nfs {
  package { 'nfs':
    ensure => absent,
  }
}
