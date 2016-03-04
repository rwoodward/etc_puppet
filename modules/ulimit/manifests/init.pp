# manage ulimit settings configuration files
class ulimit {

  file {'/etc/security/limits.conf':
    source => 'puppet:///modules/ulimit/limits.conf',
    owner => 'root',
    group => 'root',
    mode => '0644',
  }

  file {'/etc/security/limits.d/90-nproc.conf':
    source => 'puppet:///modules/ulimit/90-nproc.conf',
    owner => 'root',
    group => 'root',
    mode => '0644',
  }

  file {'/etc/pam.d/su':
    source => 'puppet:///modules/ulimit/su',
    owner => 'root',
    group => 'root',
    mode => '0644',
  }
}
