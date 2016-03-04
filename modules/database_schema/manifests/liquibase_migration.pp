# == Define database_schema::liquibase_migration
#
# Ensures that a directory of migration scripts are applied to a database.
#
# === Parameters
#
# [*changelog_source*]
#  Require path to a changelog file containing a liquibase changelog. 
#  Supports puppet and file schemas.
# [*db_username*]
#  Required username to use when connecting to database.
# [*db_password*]
#  Required password to use when connecting to database.
# [*jdbc_url*]
#  Required jdbc formatted database connection string.
# [*liquibase_path*]
#  Path to the liquibase executable. Defaults to "/opt/liquibase".
# [*default_schema*]
#  Default schema to apply migrations to.
# [*ensure*]
#  Only supported value is "latest".
#
define database_schema::liquibase_migration (
  $sqlstatement,
  $split_statements,
  $changeset_id,
  $db_username,
  $db_password,
  $jdbc_url,
  $liquibase_path,
  $default_schema      = undef,
  $ensure              = latest,
  $sql_transaction     = false
){
  $title_hash   = sha1(title)
  
  if ($::kernel == 'windows') {
    $staging_path = "${liquibase_path}\\liquibase-migration-${title_hash}"
    $changelog_path = "${staging_path}\\${title}.json"
    $liquibase_base_command = "liquibase.bat --username=${db_username} --password=${db_password} --url=\"${jdbc_url}\" --changeLogFile=\"${changelog_path}\""
    $liquibase_onlyif = "| findstr \"change sets have not been applied\""
  } else {
    $staging_path = "${liquibase_path}/liquibase-migration-${title_hash}"
    $changelog_path = "${staging_path}/${title}.json"
    $liquibase_base_command = "liquibase --username=${db_username} --password=${db_password} --url=\"${jdbc_url}\" --changeLogFile=\"${changelog_path}\""
    $liquibase_onlyif = "| grep 'change sets have not been applied'"
  }  

  if !defined(File["${staging_path}"]) {
    file { $staging_path:
      ensure  => directory
    }
  }
  
  file { $changelog_path:
    ensure => file,
    content => template("database_schema/exec_sql.json.erb"),
    require => File[$staging_path]
  }
  
  if $default_schema == undef {
    $liquibase_command = $liquibase_base_command
  } else {
    $liquibase_command = "${liquibase_base_command} --defaultSchemaName='${default_schema}'"
  }
  
  exec { "Migration for ${title}":
    cwd     => $liquibase_path,
    path    => ["${liquibase_path}", "C:\\Windows\\System32", "$java::java_directory\\bin", "$java::java_directory/bin", "/usr/bin", "/bin"],
    onlyif  => "${liquibase_command} status ${liquibase_onlyif}",
    command => "${liquibase_command} update",
    require => [ File[$changelog_path] ]
  }
}
