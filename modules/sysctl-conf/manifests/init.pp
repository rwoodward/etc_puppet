# manage sysctl-conf
class sysctl-conf {

  file {'/etc/sysctl.conf':
    source => 'puppet:///modules/sysctl-conf/sysctl.conf',
    owner => 'root',
    group => 'root',
    mode => '0644',
  }
}
