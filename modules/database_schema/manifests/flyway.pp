# == Class database_schema::flyway
#
# Ensures flyway is installed from maven or a custom source.
# 
# === Parameters
#
# [*ensure*]
#  present or absent
# [*version*]
#  The version of flyway to install. Must be a version available on maven 
#  central, or if installing from source must be the version number 
#  contained in the root folder name of the archive. Defaults to "3.1".
# [*source*]
#  Path to a tar.gz archive to install if not installing from maven central.
# [*target_dir*]
#  Directory to install flyway in. Defaults to "/opt".
# [*manage_java*]
#  If true, ensure java is installed before flyway migrations are ensured.
#  Defaults to true.
#
class database_schema::flyway (
  $ensure      = present,
  $version     = '3.1',
  $db_username,
  $db_password,
  $jdbc_url,
  $schema_source
) inherits database_schema::params {
  $real_source = $source ? {
    undef   => "http://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${version}/flyway-commandline-${version}.${source_extension}",
    default => $source
  }

  if $ensure == present and $manage_java {
    if !defined(Class[java]) {
      class { "java":
      }
    }
  }

  staging::file { "flyway-commandline-${version}.${source_extension}":
    source => $real_source
  }
  
  staging::extract { "flyway-commandline-${version}.${source_extension}":
    target => $target_dir,
    require => Staging::File["flyway-commandline-${version}.${source_extension}"]
  }
 
  if ($::kernel == 'windows') {
    $flyway_path = "$target_dir\\flyway-${version}"
  } else {
    $flyway_path = "$target_dir/flyway-${version}"
  }
 
  class { "database_schema::flyway_migration":
    db_username => $db_username,
    db_password => $db_password,
    jdbc_url => $jdbc_url,
    schema_source => $schema_source,
    flyway_path => $flyway_path,
    require => [ Staging::Extract["flyway-commandline-${version}.${source_extension}"],
                 Class["java"] ]
  }
}