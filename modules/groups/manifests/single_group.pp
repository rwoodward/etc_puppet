# definition to manage creation of groups
define groups::single_group ( $gid = 'none') {

  $groupname = $name
  $local_gid = $gid

  if $gid != 'none' {
    group { "${groupname}":
      ensure => present,
      gid => $local_gid,
      before => Class['users'],
    }
  } else {
    group { "${groupname}":
      ensure => present,
      before => Class['users'],
    }
  }
}
