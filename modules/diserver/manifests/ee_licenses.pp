# Class to fetch and install Pentaho Enterprise Development Licenses
class diserver::ee_licenses (
  $license_installer_path = "$diserver::params::license_installer_path",
  $license_files_path = "$diserver::params::license_files_path"
) {
  include staging
  
  # Ensure the Pentaho Enterprise License installer application is available
  file {"$license_installer_path":
    ensure => directory
  }

  # Fetch the licenses from remote source
#  staging::file { "paz.lic":
#    source => "$license_files_path/Pentaho%20Analysis%20Enterprise%20Edition.lic"
#  }
  
#  staging::file { "pdd.lic":
#    source => "$license_files_path/Pentaho%20Dashboard%20Designer.lic"
#  }
  
#  staging::file { "pentaho_reporting.lic":
#    source => "$license_files_path/Pentaho%20Reporting%20Enterprise%20Edition.lic"
#  }
  
#  staging::file { "pentaho_mobile.lic":
#    source => "$license_files_path/Pentaho%20Mobile.lic"
#  }
  
  staging::file { "dis-bis.lic":
    source => "$license_files_path/Pentaho%20BI%20Platform%20Enterprise%20Edition.lic"
  }
  
  staging::file { "dis-pdi.lic":
    source => "$license_files_path/Pentaho%20PDI%20Enterprise%20Edition.lic"
  }
  
  staging::file { "dis-pentaho_hadoop.lic":
    source => "$license_files_path/Pentaho%20Hadoop%20Enterprise%20Edition.lic"
  }
  
  # Setup executable license installer command
  if ($::kernel == 'windows') {
    $install_exec = 'install_license.bat'
    $install_path = [$license_installer_path]
  } else {
    $install_exec = 'install_license.sh'
    $install_path = [$license_installer_path, '/bin', '/usr/bin']
  }
  
  # Install each license
#  exec { "$install_exec install -q ${staging::path}/${caller_module_name}/paz.lic":
#    path => $install_path,
#    cwd => "$license_installer_path",
#    require => [Staging::File["paz.lic"],
#                File["$license_installer_path"] ]
#  }
  
#  exec { "$install_exec install -q ${staging::path}/${caller_module_name}/pdd.lic":
#    path => $install_path,
#    cwd => "$license_installer_path",
#    require => [Staging::File["pdd.lic"],
#                File["$license_installer_path"] ]
#  }
  
#  exec { "$install_exec install -q ${staging::path}/${caller_module_name}/pentaho_reporting.lic":
#    path => $install_path,
#    cwd => "$license_installer_path",
#    require => [Staging::File["diserver_reporting.lic"],
#                File["$license_installer_path"] ]
#  }
  
#  exec { "$install_exec install -q ${staging::path}/${caller_module_name}/pentaho_mobile.lic":
#    path => $install_path,
#    cwd => "$license_installer_path",
#    require => [Staging::File["diserver_mobile.lic"],
#                File["$license_installer_path"] ]
#  }
  
  exec { "$install_exec install -q ${staging::path}/${caller_module_name}/dis-bis.lic":
    path => $install_path,
    cwd => "$license_installer_path",
    require => [Staging::File["dis-bis.lic"],
                File["$license_installer_path"] ]
  }
  
  exec { "$install_exec install -q ${staging::path}/${caller_module_name}/dis-pdi.lic":
    path => $install_path,
    cwd => "$license_installer_path",
    require => [Staging::File["dis-pdi.lic"],
                File["$license_installer_path"] ]
  }
  
  exec { "$install_exec install -q ${staging::path}/${caller_module_name}/dis-pentaho_hadoop.lic":
    path => $install_path,
    cwd => "$license_installer_path",
    require => [Staging::File["dis-pentaho_hadoop.lic"],
                File["$license_installer_path"] ]
  }
}
