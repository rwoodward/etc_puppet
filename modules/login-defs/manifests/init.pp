# manage /etc/login.defs
class login-defs ($uidmin='500') {

  file { '/etc/login.defs':
    content => template('login-defs/login.defs.erb'),
    owner => 'root',
    group => 'root',
    mode => '0644',
  }
}
