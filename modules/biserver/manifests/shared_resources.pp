class biserver::shared_resources (
  $installer_root_dir = "$biserver::installer_root_dir"
) {
  file { ["$biserver::root_dir","$installer_root_dir"]:
    ensure => directory
  }
}