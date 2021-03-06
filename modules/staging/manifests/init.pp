#   This module manages staging and extraction of files from various sources.
#
# #### Actions:
#
#   Creates the root staging directory. By default files will be created in a subdirectory matching the caller_module_name.
#
#      /opt/staging/
#                 |-- puppet
#                 |   `-- puppet.enterprise.2.0.tar.gz
#                 `-- tomcat
#                     `-- tomcat.5.0.tar.gz
#
class staging (
  $path      = $staging::params::path,     #: staging directory filepath
  $owner     = $staging::params::owner,    #: staging directory owner
  $group     = $staging::params::group,    #: staging directory group
  $mode      = $staging::params::mode,     #: staging directory permission
  $exec_path = $staging::params::exec_path #: executable default path
) inherits staging::params {
  if ($::kernel == 'windows') {
    $7zip_install_dir = "c:/opt/7zip"
    
    class { "7zip" :
      install_directory => "$7zip_install_dir"
    }
  }

  # Resolve conflict with pe_staging
  if !defined(File[$path]) {
    file { $path:
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    }
  }

}
