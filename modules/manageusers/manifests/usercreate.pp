# manage creation of users
define users::usercreate ( $uid = 'none') {

  if $uid != 'none' {
    user { "$name":
      ensure => present,
      home => "/home/$name",
      managehome => true,
      groups => ["wheel"],
      uid => $uid,
      password => '$6$lyQv9jah$FVWZeFUb6QzjoNL1kJYtG.ZsnIj86H9KptX/2Tt.gp5AE/FXSmjM9p1fZ.t2zjpKbiKi0ssC/5TVf4hEDDZ1z/',
    }
  } else {
    user { "$name":
      ensure => present,
      home => "/home/$name",
      managehome => true,
      groups => ["wheel"],
      password => '$6$lyQv9jah$FVWZeFUb6QzjoNL1kJYtG.ZsnIj86H9KptX/2Tt.gp5AE/FXSmjM9p1fZ.t2zjpKbiKi0ssC/5TVf4hEDDZ1z/',
    }
  }
}
