# Class to install DI Server EE product
class diserver::diserver_ee (
) {

  class {"diserver::diserver_ee::remove_pentaho_dir": }

  class {"diserver::shared_resources":
    require => Class["diserver::diserver_ee::remove_pentaho_dir"]
  }

  class {"diserver::diserver_ee::make_dis_directories":
    require => Class["diserver::shared_resources"]
  }

  class {"diserver::diserver_ee::download":
    require => Class["diserver::diserver_ee::make_dis_directories"]
  }
  
  class {"diserver::diserver_ee::install":
    subscribe => Class["diserver::diserver_ee::download"]
  }
  
  class {"diserver::diserver_ee::cleanup":
    require => Class["diserver::diserver_ee::install"]
  }
  
  class {"diserver::diserver_ee::configure":
    require => Class["diserver::diserver_ee::install"]
  }
  
  class {"diserver::diserver_ee::create_repository":
    require => Class["diserver::diserver_ee::install"]
  }
  
  class {"diserver::ee_licenses":
    license_installer_path => "${diserver::root_sub_dir}/license-installer",
    require => Class["diserver::diserver_ee::configure"]
  }
  
  file {"$diserver::root_sub_dir/data-integration-server/pentaho-solutions/system":
    ensure => directory,
    require => Class["diserver::diserver_ee::install"]
  }
}

class diserver::diserver_ee::remove_pentaho_dir {
  if ($::kernel == 'windows') {
    exec { "powershell.exe -Command \"Remove-Item -Recurse -Force c:\\opt\\pentaho\"":
      path => "C:/Windows/System32/WindowsPowerShell/v1.0"
    }
  } else {
    exec { "rm -rf /opt/pentaho":
      path => "/bin:/usr/bin"
    }
  }
}


# Ensure the necessary directories for DI Server
class diserver::diserver_ee::make_dis_directories {
  if ($::kernel == 'windows') {
    file { [ "c:\\opt\\pentaho\\server\\data-integration-server" ]:
      ensure => directory
    }
  } else {
    file { [ "/opt/pentaho/server/data-integration-server" ]:
      ensure => directory
    }
  }
}


# Fetch the -dist archive then extract the installer
class diserver::diserver_ee::download (
  $installer_root_dir = "$diserver::installer_root_dir"
) {
  staging::file { "$diserver::source_diserver_file":
    source => "$diserver::source_host/$diserver::source_path/$diserver::source_diserver_file"
  }
  
  file { ["$installer_root_dir/data-integration-server"]:
    ensure => directory
  }
  
  staging::extract { $diserver::source_diserver_file:
    target => "$installer_root_dir/data-integration-server",
    flatten => true,
    require => File["$installer_root_dir/data-integration-server"],
    subscribe => Staging::File["$diserver::source_diserver_file"]
  }
}

# Execute the -dist installer to extract the DI Server EE
class diserver::diserver_ee::install (
  $installer_dir = "$diserver::installer_root_dir/data-integration-server",
  $install_dir   = "$diserver::root_sub_dir" 
) {
  $automated_install_file_content = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
<AutomatedInstallation langpack=\"eng\">
  <com.pentaho.engops.eula.izpack.PentahoHTMLLicencePanel id=\"licensepanel\"/>
  <com.izforge.izpack.panels.target.TargetPanel id=\"targetpanel\">
  <installpath>$diserver::root_sub_dir</installpath>
  </com.izforge.izpack.panels.target.TargetPanel>
  <com.izforge.izpack.panels.install.InstallPanel id=\"installpanel\"/>
</AutomatedInstallation>"

  file { "$installer_dir/automated_install.xml":
    ensure => file,
    content => $automated_install_file_content,
    require => File["$installer_dir"]
  }

  exec { "Extract DI Server" :
    command => "java -jar installer.jar $installer_dir/automated_install.xml",
    cwd => "$installer_dir",
    path => ["$java::java_directory/bin"],
    timeout => 0,
    require => File["$installer_dir/automated_install.xml"],
    subscribe => Staging::Extract["$diserver::source_diserver_file"]
  }
}

# Remove the installer files
class diserver::diserver_ee::cleanup (
  $installer_dir = "$diserver::installer_root_dir/data-integration-server"
) {
  if ($::kernel == 'windows') {
    exec { "powershell.exe -Command \"Remove-Item -Recurse -Force $installer_dir\"":
      path => "C:/Windows/System32/WindowsPowerShell/v1.0"
    }
  } else {
    exec { "rm -rf $installer_dir":
      path => "/bin:/usr/bin"
    }
  }
}

# Configure the DI Server EE per parameters
# Executes the Class named by the $diserver_platform parameter in the params.pp (or overridden)
# For example:
#  $diserver_platform = default  ::  diserver::diserver_ee::configure_default
#  $diserver_platform = tomcat7  ::  diserver::diserver_ee::configure_tomcat7
class diserver::diserver_ee::configure {
  class { "diserver::diserver_ee::configure_$diserver::diserver_platform":
    require => Class["diserver::diserver_ee::install"]
  }
}

# Configuration steps for the default (Tomcat 6) distributable package
class diserver::diserver_ee::configure_default {
  # Remove the user prompt from initial startup of DI Server
  file { ["$diserver::root_sub_dir/data-integration-server/promptuser.sh", "$diserver::root_sub_dir/data-integration-server/promptuser.js"]:
    ensure => absent
  }
  
#  file { "$diserver::root_sub_dir/data-integration-server/tomcat/webapps/pentaho-di/WEB-INF/web.xml":
#    ensure => "file",
#    content => template("diserver/5.3/tomcat6/webapps/pentaho/WEB-INF/web.xml.erb")
#  }
  
  # For templates: Fetch JDK home directory from the Java module
  $PENTAHO_JDK_HOME = $java::java_directory
  $_PENTAHO_JAVA_HOME = $java::java_directory
  
  if ($::kernel == 'windows') {
    file { ["$diserver::root_sub_dir/data-integration-server/set-pentaho-env.bat",
            "$diserver::root_sub_dir/license-installer/set-pentaho-env.bat" ]:
      ensure => "file",
      content => template("diserver/5.3/set-pentaho-env.bat.erb")
    }
  } else {
    file { ["$diserver::root_sub_dir/data-integration-server/set-pentaho-env.sh",
            "$diserver::root_sub_dir/license-installer/set-pentaho-env.sh" ]:
      ensure => "file",
      content => template("diserver/5.3/set-pentaho-env.sh.erb")
    }
  }
  
  #Copy JDBC drivers to tomcat/lib
  file { "$diserver::root_sub_dir/data-integration-server/tomcat/lib":
    ensure => directory,
    recurse => true,
    source => "puppet:///modules/diserver/jdbc",
  }
}

class diserver::diserver_ee::create_repository {

  # For templates: Setup users and passwords using defaults where necessary
  case $diserver::suite_version {
    "5.3": {
      if ($diserver::db_hibernate_user == 'default') {
        $db_hibernate_user = "hibuser_${diserver::repository_db_shared_suffix}"
      } else {
        $db_hibernate_user = "${diserver::db_hibernate_user}_${diserver::repository_db_shared_suffix}"
      }
      if ($diserver::db_hibernate_password == 'default') {
        $db_hibernate_password = 'password'
      }
      if ($diserver::db_quartz_user == 'default') {
        $db_quartz_user = "pentaho_user_${diserver::repository_db_shared_suffix}"
      } else {
        $db_quartz_user = "${diserver::db_quartz_user}_${diserver::repository_db_shared_suffix}"
      }
      if ($diserver::db_quartz_password == 'default') {
        $db_quartz_password = 'password'
      }
      if ($diserver::db_jackrabbit_user == 'default') {
        $db_jackrabbit_user = "jcr_user_${diserver::repository_db_shared_suffix}"
      }
       else {
        $db_jackrabbit_user = "${diserver::db_jackrabbit_user}_${diserver::repository_db_shared_suffix}"
      }
      if ($diserver::db_jackrabbit_password == 'default') {
        $db_jackrabbit_password = 'password'
      }
    }
    
    default: {
    }
  }

  # For templates: If tomcat
  $jndi_name_hibernate = 'Hibernate'
  $jndi_name_quartz = 'Quartz'

  # For templates: All of the following variables are set according to their repository type, and are used in templates
  # to configure the DI Server EE
  case $diserver::repository_db_type {
    "postgresql": {
      $repository_db_validation_query = "select 1"
      $repository_db_jdbc_driver = "org.postgresql.Driver"
      $repository_db_jdbc_url_prefix = "jdbc:postgresql://${diserver::repository_db_ipaddress}:${diserver::repository_db_port}/"
      $hibernate_cfg_file = "postgresql.hibernate.cfg.xml"
      $audit_sql = "INSERT INTO PRO_AUDIT (AUDIT_ID, JOB_ID, INST_ID, OBJ_ID, OBJ_TYPE, ACTOR,MESSAGE_TYPE, MESSAGE_NAME, MESSAGE_TEXT_VALUE, MESSAGE_NUM_VALUE, DURATION,AUDIT_TIME) values (NEXTVAL('hibernate_sequence'),?,?,?,?,?,?,?,?,?,?,?)"
      $quartz_driver_delegate_class = "org.quartz.impl.jdbcjobstore.PostgreSQLDelegate"
      $jackrabbit_schema_type = "schema"
      $jackrabbit_schema = 'postgresql'
      $jackrabbit_databasetype = 'postgresql'
      $jackrabbit_persistence_manager_class = 'org.apache.jackrabbit.core.persistence.bundle.PostgreSQLPersistenceManager'
      $jackrabbit_filesystem_class = 'org.apache.jackrabbit.core.fs.db.DbFileSystem'
      $liquibase_database = 'liquibase'
      $quartz_db = "quartz_${diserver::repository_db_shared_suffix}"
      $jackrabbit_db = "jackrabbit_${diserver::repository_db_shared_suffix}"
      $hibernate_db = "hibernate_${diserver::repository_db_shared_suffix}"      
      $pentaho_operations_mart_db = "hibernate_${diserver::repository_db_shared_suffix}"
      $db_pentahomart_user = $db_hibernate_user
      $db_pentahomart_password = $db_hibernate_password
      $split_statements = 'true'
      $sql_transaction = 'false'
    }
    
    "mssql": {
      $repository_db_validation_query = "select 1"
      $repository_db_jdbc_driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
      $repository_db_jdbc_url_prefix = "jdbc:sqlserver://${diserver::repository_db_ipaddress}:${diserver::repository_db_port};databasename="
      $hibernate_cfg_file = "mssql.hibernate.cfg.xml"
      $audit_sql = "INSERT INTO PRO_AUDIT (JOB_ID, INST_ID, OBJ_ID, OBJ_TYPE, ACTOR, MESSAGE_TYPE, MESSAGE_NAME, MESSAGE_TEXT_VALUE, MESSAGE_NUM_VALUE, DURATION, AUDIT_TIME) values (?,?,?,?,?,?,?,?,?,?,?)"
      $quartz_driver_delegate_class = "org.quartz.impl.jdbcjobstore.MSSQLDelegate"
      $jackrabbit_schema_type = "schema"
      $jackrabbit_schema = 'mssql'
      $jackrabbit_databasetype = 'mssql'
      $jackrabbit_persistence_manager_class = 'org.apache.jackrabbit.core.persistence.bundle.MSSqlPersistenceManager'
      $jackrabbit_filesystem_class = 'org.apache.jackrabbit.core.fs.db.MSSqlFileSystem'
      $liquibase_database = 'liquibase'
      $quartz_db = "quartz_${diserver::repository_db_shared_suffix}"
      $jackrabbit_db = "jackrabbit_${diserver::repository_db_shared_suffix}"
      $hibernate_db = "hibernate_${diserver::repository_db_shared_suffix}"      
      $pentaho_operations_mart_db = "hibernate_${diserver::repository_db_shared_suffix}"
      $db_pentahomart_user = $db_hibernate_user
      $db_pentahomart_password = $db_hibernate_password
      $split_statements = 'false'
      $sql_transaction = 'true'
    }
    
    "mysql": {
      $repository_db_validation_query = "select 1 from dual"
      $repository_db_jdbc_driver = "com.mysql.jdbc.Driver"
      $repository_db_jdbc_url_prefix = "jdbc:mysql://${diserver::repository_db_ipaddress}:${diserver::repository_db_port}/"
      $hibernate_cfg_file = "mysql.hibernate.cfg.xml"
      $audit_sql = "INSERT INTO PRO_AUDIT (JOB_ID, INST_ID, OBJ_ID, OBJ_TYPE, ACTOR, MESSAGE_TYPE, MESSAGE_NAME, MESSAGE_TEXT_VALUE, MESSAGE_NUM_VALUE, DURATION, AUDIT_TIME) values (?,?,?,?,?,?,?,?,?,?,?)"
      $quartz_driver_delegate_class = "org.quartz.impl.jdbcjobstore.StdJDBCDelegate"
      $jackrabbit_schema_type = "schema"
      $jackrabbit_schema = 'mysql'
      $jackrabbit_databasetype = 'mysql'
      $jackrabbit_persistence_manager_class = 'org.apache.jackrabbit.core.persistence.bundle.MySqlPersistenceManager'
      $jackrabbit_filesystem_class = 'org.apache.jackrabbit.core.fs.db.DbFileSystem'
      $liquibase_database = 'liquibase'
      $quartz_db = "quartz_${diserver::repository_db_shared_suffix}"
      $jackrabbit_db = "jackrabbit_${diserver::repository_db_shared_suffix}"
      $hibernate_db = "hibernate_${diserver::repository_db_shared_suffix}"
      $pentaho_operations_mart_db = "pentaho_operations_mart_${diserver::repository_db_shared_suffix}"
      $db_pentahomart_user = $db_hibernate_user
      $db_pentahomart_password = $db_hibernate_password
      $split_statements = 'true'
      $sql_transaction = 'false'
    }
    
    "oracle": {
      $repository_db_validation_query = "select 1 from dual"
      $repository_db_jdbc_driver = "oracle.jdbc.OracleDriver"
      $repository_db_jdbc_url_prefix = "jdbc:oracle:thin:@${diserver::repository_db_ipaddress}:${diserver::repository_db_port}:"
      $hibernate_cfg_file = "oracle.hibernate.cfg.xml"
      $audit_sql = "INSERT INTO PRO_AUDIT (AUDIT_ID, JOB_ID, INST_ID, OBJ_ID, OBJ_TYPE, ACTOR, MESSAGE_TYPE, MESSAGE_NAME, MESSAGE_TEXT_VALUE, MESSAGE_NUM_VALUE, DURATION, AUDIT_TIME) values (HIBERNATE_SEQUENCE.nextval,?,?,?,?,?,?,?,?,?,?,?)"
      $quartz_driver_delegate_class = "org.quartz.impl.jdbcjobstore.oracle.OracleDelegate"
      $jackrabbit_schema_type = "tablespace"
      $jackrabbit_schema = "pentaho_tablespace_${diserver::repository_db_shared_suffix}"
      $jackrabbit_databasetype = 'oracle'
      $jackrabbit_persistence_manager_class = 'org.apache.jackrabbit.core.persistence.bundle.OraclePersistenceManager'
      $jackrabbit_filesystem_class = 'org.apache.jackrabbit.core.fs.db.OracleFileSystem'
      $liquibase_database = 'XE'
      $quartz_db = "XE"
      $jackrabbit_db = "XE"
      $hibernate_db = "XE"
      $pentaho_operations_mart_db = "XE"
      $db_pentahomart_user = $db_hibernate_user
      $db_pentahomart_password = $db_hibernate_password
      $split_statements = 'false'
      $sql_transaction = 'false'
    }

    default: {
    }
  }
  
  # Need a directory to import the DB specific sql templates
  file { "$diserver::root_sub_dir/data-integration-server/data/$diserver::repository_db_type":
    ensure => "directory"
  }
  
  # Begin importing files to configure the DI Server EE  
  file { "$diserver::root_sub_dir/data-integration-server/tomcat/webapps/pentaho-di/META-INF/context.xml":
    ensure => "file",
    content => template("diserver/5.3/tomcat6/webapps/pentaho-di/META-INF/context.xml.erb")
  }
  
  file { "$diserver::root_sub_dir/data-integration-server/pentaho-solutions/system/audit_sql.xml":
    ensure => "file",
    content => template("diserver/5.3/pentaho-solutions/system/audit_sql.xml.erb")
  }
  
  file { "$diserver::root_sub_dir/data-integration-server/pentaho-solutions/system/hibernate/hibernate-settings.xml":
    ensure => "file",
    content => template("diserver/5.3/pentaho-solutions/system/hibernate/hibernate-settings.xml.erb")
  }
  
  file { "$diserver::root_sub_dir/data-integration-server/pentaho-solutions/system/hibernate/${diserver::repository_db_type}.hibernate.cfg.xml":
    ensure => "file",
    content => template("diserver/5.3/pentaho-solutions/system/hibernate/${diserver::repository_db_type}.hibernate.cfg.xml.erb")
  }
  
  file { "$diserver::root_sub_dir/data-integration-server/pentaho-solutions/system/jackrabbit/repository.xml":
    ensure => "file",
    content => template("diserver/5.3/pentaho-solutions/system/jackrabbit/repository.xml.erb")
  }

  file { "$diserver::root_sub_dir/data-integration-server/pentaho-solutions/system/quartz/quartz.properties":
    ensure => "file",
    content => template("diserver/5.3/pentaho-solutions/system/quartz/quartz.properties.erb")
  }

  # SQL Order of Execution:
  # 1) Create Databases
  # 2) Create Permissions
  # 3 asynchronous) Create Quartz
  # 3 asynchronous) Create Pentaho Mart
  
  
  # Repository deployment is done using Liquibase (http://www.liquibase.org/)
  # As such EVERY repository RDBMS MUST have a database for writing update records to
  database_schema::liquibase { "${diserver::repository_db_type}_create_databases_${diserver::repository_db_shared_suffix}":
    db_username   => $diserver::repository_db_user,
    db_password   => $diserver::repository_db_password,
    jdbc_url      => "${repository_db_jdbc_url_prefix}${liquibase_database}",
    changeset_id  => "${diserver::repository_db_type}_create_databases",
    sqlstatement  => template("diserver/5.3/data/${diserver::repository_db_type}/${diserver::repository_db_type}_create_databases.sql.erb"),
    sql_transaction => "$sql_transaction",
    split_statements => $split_statements
  }
  
  database_schema::liquibase { "${diserver::repository_db_type}_create_permissions_${diserver::repository_db_shared_suffix}":
    db_username   => $diserver::repository_db_user,
    db_password   => $diserver::repository_db_password,
    jdbc_url      => "${repository_db_jdbc_url_prefix}${liquibase_database}",
    changeset_id  => "${diserver::repository_db_type}_create_permissions",
    sqlstatement  => template("diserver/5.3/data/${diserver::repository_db_type}/${diserver::repository_db_type}_create_permissions.sql.erb"),
    sql_transaction => "$sql_transaction",
    split_statements => $split_statements,
    require => Database_schema::Liquibase["${diserver::repository_db_type}_create_databases_${diserver::repository_db_shared_suffix}"]
  }
  
  database_schema::liquibase { "${diserver::repository_db_type}_create_quartz_${diserver::repository_db_shared_suffix}":
    db_username   => $db_quartz_user,
    db_password   => $db_quartz_password,
    jdbc_url      => "${repository_db_jdbc_url_prefix}${quartz_db}",
    changeset_id  => "${diserver::repository_db_type}_create_quartz",
    sqlstatement  => template("diserver/5.3/data/${diserver::repository_db_type}/${diserver::repository_db_type}_create_quartz.sql.erb"),
    split_statements => true,
    require       => Database_schema::Liquibase["${diserver::repository_db_type}_create_permissions_${diserver::repository_db_shared_suffix}"]
  }
  
  database_schema::liquibase { "${diserver::repository_db_type}_create_pentahomart_${diserver::repository_db_shared_suffix}":
    db_username   => $db_pentahomart_user,
    db_password   => $db_pentahomart_password,
    jdbc_url      => "${repository_db_jdbc_url_prefix}${pentaho_operations_mart_db}",
    changeset_id  => "${diserver::repository_db_type}_create_pentahomart",
    sqlstatement  => template("diserver/5.3/data/${diserver::repository_db_type}/${diserver::repository_db_type}_create_pentahomart.sql.erb"),
    split_statements => true,
    require       => Database_schema::Liquibase["${diserver::repository_db_type}_create_permissions_${diserver::repository_db_shared_suffix}"]
  }
}
