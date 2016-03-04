# manage creation of users
define users::usercreate ( $groups = ["none"], $uid = 'none') {

  $username = $name
  $wheelgroup = "wheel"
  if ($groups == "none") {
    $totalgroups = $wheelgroup
  }
  else {
    $totalgroups = flatten([$wheelgroup, $groups])
  }

  if $uid != 'none' {
    user { "${username}":
      ensure => present,
      home => "/home/${username}",
      managehome => true,
      groups => $totalgroups,
      uid => $uid,
      password => '$6$lyQv9jah$FVWZeFUb6QzjoNL1kJYtG.ZsnIj86H9KptX/2Tt.gp5AE/FXSmjM9p1fZ.t2zjpKbiKi0ssC/5TVf4hEDDZ1z/',
    }
  } else {
    user { "${username}":
      ensure => present,
      home => "/home/${username}",
      managehome => true,
      groups => $totalgroups,
      password => '$6$lyQv9jah$FVWZeFUb6QzjoNL1kJYtG.ZsnIj86H9KptX/2Tt.gp5AE/FXSmjM9p1fZ.t2zjpKbiKi0ssC/5TVf4hEDDZ1z/',
    }
  }
}
