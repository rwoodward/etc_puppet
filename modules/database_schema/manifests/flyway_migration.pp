# == Define database_schema::flyway_migration
#
# Ensures that a directory of migration scripts are applied to a database.
#
# === Parameters
#
# [*schema_source*]
#  Require path to a source directory containing sql migration scripts. 
#  Supports puppet and file schemas.
# [*db_username*]
#  Required username to use when connecting to database.
# [*db_password*]
#  Required password to use when connecting to database.
# [*jdbc_url*]
#  Required jdbc formatted database connection string.
# [*flyway_path*]
#  Path to the flyway executable. Defaults to "/opt/flyway-3.1".
# [*target_schemas*]
#  Schemas to apply migrations to, provided as a list of schema names.
# [*ensure*]
#  Only supported value is "latest".
#
class database_schema::flyway_migration (
  $schema_source,
  $db_username,
  $db_password,
  $jdbc_url,
  $flyway_path,
  $target_schemas      = undef,
  $ensure              = latest
){
  $title_hash   = sha1(title)
  $staging_path = "$database_schema::flyway::target_dir\\${title_hash}"
  file { "$staging_path":
    ensure  => directory,
    recurse => true,
    source  => $schema_source
  }
  
  $flyway_base_command = "flyway.cmd -user=${db_username} -password=${db_password} -url=\"${jdbc_url}\" -locations=\"filesystem:${staging_path}\""
  
  if $target_schemas == undef {
    $flyway_command = $flyway_base_command
  }
  else {
    $joined_schemas = join($target_schemas, ',')
    $flyway_command = "${flyway_base_command} -schemas='${joined_schemas}'"
  }
  
  exec { "Migration for ${title}":
    cwd     => $flyway_path,
    environment => ["JAVA_HOME=$java::java_directory"],
    path    => "${flyway_path}",
    unless  => "${flyway_command} validate",
    command => "${flyway_command} migrate",
    require => File[$staging_path]
  }
}