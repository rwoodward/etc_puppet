class java (
  $install_directory = "$java::params::install_directory",
  $ensure           = "present",
  $type = "$java::params::type",
  $version = "$java::params::version"
) inherits java::params {
#  validate_re($::kernel, '^([Ll]inux|[Ww]indows)$', 'This module only supports Linux and Windows')
  
  case $architecture {
    "x64": {
      $arch = "64"
    }
    default: {
      $arch = $architecture
    }
  }
  
  $java_archive = "$type$version-$::kernel-$arch.$archive_type"
  
  if !defined(File[$install_directory]) {
    file { "$install_directory":
      source_permissions => ignore,
      ensure => directory
    }
  }

  staging::file { "$java_archive":
    timeout => 0,
    source => "$java_archive_source/$java_archive",
  }

  staging::extract { "$java_archive":
    target => "$install_directory",
    require => [File["$install_directory"],
                Staging::File["$java_archive"] ]
  }

#  if ($::kernel == "Darwin") {
#    exec { 'change-owner' :
#      command => "/usr/sbin/chown -R root:wheel $install_directory",
#      path => '/bin',
#      require => Staging::Extract["$java_archive"],
#    }
#  }
  
  if $version == "7u75" {
    if ($::kernel == "Darwin") {
      $java_directory = "/Library/Java/JavaVirtualMachines/jdk1.7.0_51.jdk/Contents/Home/"
    } elsif ($::kernel == 'windows') {
      case $type {
        "jdk": {
          $java_directory = "$install_directory\jdk1.7.0_75"
        }

        "jre": {
          $java_directory = "$install_directory\jre1.7.0_75"
        }
      }
    } else {
      case $type {
        "jdk": {
          $java_directory = "$install_directory/jdk1.7.0_75"
        }

        "jre": {
          $java_directory = "$install_directory/jre1.7.0_75"
        }
      }
    }
  }
  if $version == "8u60" {
    if ($::kernel == "Darwin") {
      $java_directory = "/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Home/"
    } elsif ($::kernel == 'windows') {
      case $type {
        "jdk": {
          $java_directory = "$install_directory\jdk-8u60-windows-x64"
        }

        "jre": {
          $java_directory = "$install_directory\jre-8u60-windows-x64"
        }
      }
    } else {
      case $type {
        "jdk": {
          $java_directory = "$install_directory/jdk1.8.0_60"
        }

        "jre": {
          $java_directory = "$install_directory/jre1.8.0_60"
        }
      }
    }
  }
}
