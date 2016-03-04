# manage kerberos client install
class kerberos {

  package { 'krb5-workstation':
    ensure => installed,
  }

  package { 'krb5-libs':
    ensure => installed,
  }

  file {'/etc/krb5.conf':
    source => 'puppet:///modules/kerberos/krb5.conf',
    owner => 'root',
    group => 'root',
    mode => '0644',
    require => Package['krb5-workstation'],
  }
}
