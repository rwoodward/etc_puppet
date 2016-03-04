class diserver::shared_resources (
  $installer_root_dir = "$diserver::installer_root_dir"
) {
  file { ["$diserver::root_dir","$diserver::root_sub_dir","$installer_root_dir"]:
    ensure => directory
  }
}
