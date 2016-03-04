# manage users
define users ( $uid = 'none', $ssh = false) {

  require login-defs

  if $name == 'root' {
    users::ssh {'root':
    }
  } else {
      users::usercreate {"$name":
        uid => $uid,
      }
  }
  if $ssh {
    users::ssh {"$name":
      require => Users::Usercreate["$name"],
    }
  }
}
