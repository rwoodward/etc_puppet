# == Class database_schema::liquibase
#
# Ensures liquibase is installed from maven or a custom source. No jdbc drivers
# are installed as part of this resource. All required jars must be placed in 
# the lib folder of this installation before ensuring migrations.
# 
# === Parameters
#
# [*ensure*]
#  present or absent
# [*version*]
#  The version of liquibase to install. Must be a version available on maven 
#  central if not installing from source. Defaults to "3.3.2".
# [*source*]
#  Path to a tar.gz archive to install if not installing from maven central.
# [*target_dir*]
#  Directory to install liquibase in. Defaults to "/opt".
# [*manage_java*]
#  If true, ensure java is installed before flyway migrations are ensured.
#  Defaults to true.
#
define database_schema::liquibase (
  $ensure      = present,
  $version     = '3.3.2',
  $changeset_id,
  $db_username,
  $db_password,
  $jdbc_url,
  $sqlstatement,
  $split_statements,
  $sql_transaction  = false
) {
  if ($::kernel == 'windows') {
    $target_dir  = 'c:\opt'
    $source_extension = 'zip'
  } else {
    $target_dir  = '/opt'
    $source_extension = 'tar.gz'
  }

  $source      = undef
  $manage_java = true


  $real_source = $source ? {
    undef   => "http://repo1.maven.org/maven2/org/liquibase/liquibase-core/${version}/liquibase-core-${version}-bin.${source_extension}",
    default => $source
  }
  
  $dir_ensure = $ensure ? {
    absent  => absent,
    default => directory
  }
  
  if $ensure == present and $manage_java {
    if !defined(Class[java]) {
      class { "java":
      }
    }
  }
  
  # If Liquibase is not installed, install it
  if !defined(File["${target_dir}/liquibase-${version}"]) {
    file { "${target_dir}/liquibase-${version}":
      ensure => $dir_ensure,
      force  => true
    }
  
    staging::file { "liquibase-core-${version}-bin.${source_extension}":
      source => $real_source
    }
  
    staging::extract { "liquibase-core-${version}-bin.${source_extension}":
      target => "$target_dir/liquibase-${version}",
      require => [ Staging::File["liquibase-core-${version}-bin.${source_extension}"],
                   File["${target_dir}/liquibase-${version}"] ]
    }
  
    #Copy JDBC drivers to liquibase/lib
    file { "$target_dir/liquibase-${version}/lib":
      ensure => directory,
      recurse => true,
      source => "puppet:///modules/database_schema/jdbc-drivers",
      require => Staging::Extract["liquibase-core-${version}-bin.${source_extension}"]
    }
  }

  if ($::kernel == 'windows') {
    $liquibase_path = "$target_dir\\liquibase-${version}"
  } else {
    $liquibase_path = "$target_dir/liquibase-${version}"
  }
  
  database_schema::liquibase_migration { "${title}" :
    db_username => $db_username,
    db_password => $db_password,
    jdbc_url => $jdbc_url,
    liquibase_path => $liquibase_path,
    sqlstatement => $sqlstatement,
    split_statements => $split_statements,
    changeset_id => $changeset_id,
    sql_transaction => $sql_transaction,
    require => [ File["$target_dir/liquibase-${version}/lib"],
                 Class["java"] ]
  }
}