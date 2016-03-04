# users class init.pp - manages user creation and ssh keys
class users ($resources = {}) {

  $defaults = {
    uid => 'none',
    ssh => false,
  }

  require login-defs

  create_resources('users::single_user', $resources, $defaults)
}

