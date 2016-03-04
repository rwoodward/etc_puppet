# groups class init.pp - manages group creation
class groups ($resources = {}) {

  $defaults = {
    gid => 'none',
  }

  require login-defs

  create_resources('groups::single_group', $resources, $defaults)
}
