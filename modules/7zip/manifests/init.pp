class 7zip (
  $install_directory = "$7zip::params::install_directory",
  $ensure           = "present"
) inherits 7zip::params {
  validate_re($::kernel, '^([Ww]indows)$', 'This module only supports Windows only')
  
  file { "$install_directory":
    source => "puppet:///modules/7zip/7-Zip32",
    source_permissions => ignore,
    recurse => true,
    ensure => directory
  }
}