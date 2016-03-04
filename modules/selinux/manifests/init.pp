# manage selinux
class selinux {

  file {'/etc/selinux/config':
    source => 'puppet:///modules/selinux/config',
    owner => 'root',
    group => 'root',
    mode => '0644',
  }
}
