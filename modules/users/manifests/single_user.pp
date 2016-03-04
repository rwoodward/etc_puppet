# users definition users::single_user.pp - manages user creation and ssh keys
define users::single_user ( $groups = [], $uid = 'none', $ssh = false) {

  $username = $name

  if $ssh {
    if $username == 'root' {
      $path = '/root'
      users::ssh {"${username}":
        path => $path,
      }
    } else {
        $path = "/home/${username}"

        users::usercreate {"${username}":
          uid => $uid,
          groups => $groups,
        }

        users::ssh {"${username}":
          path => $path,
          require => Users::Usercreate["${username}"],
        }
    }
  } else {
      users::usercreate {"${username}":
        uid => $uid,
        groups => $groups,
      }
  }
}

