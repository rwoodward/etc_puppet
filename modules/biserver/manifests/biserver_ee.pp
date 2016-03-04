# Class to install BI Server EE product
class biserver::biserver_ee (
) {
  class {"biserver::biserver_ee::download": }
  
  class {"biserver::biserver_ee::install":
    subscribe => Class["biserver::biserver_ee::download"]
  }
  
  class {"biserver::biserver_ee::cleanup":
    require => Class["biserver::biserver_ee::install"]
  }
  
  class {"biserver::biserver_ee::configure":
    require => Class["biserver::biserver_ee::install"]
  }
  
  class {"biserver::biserver_ee::create_repository":
    require => Class["biserver::biserver_ee::install"]
  }
  
  class {"biserver::ee_licenses":
    license_installer_path => "${biserver::root_dir}/license-installer",
    require => Class["biserver::biserver_ee::install"]
  }
  
  file {"$biserver::root_dir/biserver-ee/pentaho-solutions/system":
    ensure => directory,
    require => Class["biserver::biserver_ee::install"]
  }
}

# Fetch the -dist archive then extract the installer
class biserver::biserver_ee::download (
  $installer_root_dir = "$biserver::installer_root_dir"
) {
  staging::file { "$biserver::source_biserver_file":
    source => "$biserver::source_host/$biserver::source_path/$biserver::source_biserver_file"
  }
  
  file { ["$installer_root_dir/biserver-ee"]:
    ensure => directory
  }
  
  staging::extract { $biserver::source_biserver_file:
    target => "$installer_root_dir/biserver-ee",
    flatten => true,
    require => File["$installer_root_dir/biserver-ee"],
    subscribe => Staging::File["$biserver::source_biserver_file"]
  }
}

# Execute the -dist installer to extract the BI Server EE
class biserver::biserver_ee::install (
  $installer_dir = "$biserver::installer_root_dir/biserver-ee",
  $install_dir   = "$biserver::root_dir" 
) {
  $automated_install_file_content = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
<AutomatedInstallation langpack=\"eng\">
  <com.pentaho.engops.eula.izpack.PentahoHTMLLicencePanel id=\"licensepanel\"/>
  <com.izforge.izpack.panels.target.TargetPanel id=\"targetpanel\">
  <installpath>$biserver::root_dir</installpath>
  </com.izforge.izpack.panels.target.TargetPanel>
  <com.izforge.izpack.panels.install.InstallPanel id=\"installpanel\"/>
</AutomatedInstallation>"

  file { "$installer_dir/automated_install.xml":
    ensure => file,
    content => $automated_install_file_content,
    require => File["$installer_dir"]
  }

  exec { "Extract BA Server" :
    command => "java -jar installer.jar $installer_dir/automated_install.xml",
    cwd => "$installer_dir",
    path => ["$java::java_directory/bin"],
    timeout => 0,
    require => File["$installer_dir/automated_install.xml"],
    subscribe => Staging::Extract["$biserver::source_biserver_file"]
  }
}

# Remove the installer files
class biserver::biserver_ee::cleanup (
  $installer_dir = "$biserver::installer_root_dir/biserver-ee"
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

# Configure the BI Server EE per parameters
# Executes the Class named by the $biserver_platform parameter in the params.pp (or overridden)
# For example:
#  $biserver_platform = default  ::  biserver::biserver_ee::configure_default
#  $biserver_platform = tomcat7  ::  biserver::biserver_ee::configure_tomcat7
class biserver::biserver_ee::configure {
  class { "biserver::biserver_ee::configure_$biserver::biserver_platform":
    require => Class["biserver::biserver_ee::install"]
  }
}

# Configuration steps for the default (Tomcat 6) distributable package
class biserver::biserver_ee::configure_default {
  # Remove the user prompt from initial startup of BI Server
  file { ["$biserver::root_dir/biserver-ee/promptuser.sh", "$biserver::root_dir/biserver-ee/promptuser.js"]:
    ensure => absent
  }
  
  file { "$biserver::root_dir/biserver-ee/tomcat/webapps/pentaho/WEB-INF/web.xml":
    ensure => "file",
    content => template("biserver/5.3/tomcat6/webapps/pentaho/WEB-INF/web.xml.erb")
  }
  
  # For templates: Fetch JDK home directory from the Java module
  $PENTAHO_JDK_HOME = $java::java_directory
  
  if ($::kernel == 'windows') {
    file { ["$biserver::root_dir/biserver-ee/set-pentaho-env.bat",
            "$biserver::root_dir/license-installer/set-pentaho-env.bat" ]:
      ensure => "file",
      content => template("biserver/5.3/set-pentaho-env.bat.erb")
    }
  } else {
    file { ["$biserver::root_dir/biserver-ee/set-pentaho-env.sh",
            "$biserver::root_dir/license-installer/set-pentaho-env.sh" ]:
      ensure => "file",
      content => template("biserver/5.3/set-pentaho-env.sh.erb")
    }
  }
  
  #Copy JDBC drivers to tomcat/lib
  file { "$biserver::root_dir/biserver-ee/tomcat/lib":
    ensure => directory,
    recurse => true,
    source => "puppet:///modules/biserver/jdbc",
  }
}

class biserver::biserver_ee::create_repository {

  # For templates: Setup users and passwords using defaults where necessary
  case $biserver::suite_version {
    "5.3": {
      if ($biserver::db_hibernate_user == 'default') {
        $db_hibernate_user = "hibuser_${biserver::repository_db_shared_suffix}"
      } else {
        $db_hibernate_user = "${biserver::db_hibernate_user}_${biserver::repository_db_shared_suffix}"
      }
      if ($biserver::db_hibernate_password == 'default') {
        $db_hibernate_password = 'password'
      }
      if ($biserver::db_quartz_user == 'default') {
        $db_quartz_user = "pentaho_user_${biserver::repository_db_shared_suffix}"
      } else {
        $db_quartz_user = "${biserver::db_quartz_user}_${biserver::repository_db_shared_suffix}"
      }
      if ($biserver::db_quartz_password == 'default') {
        $db_quartz_password = 'password'
      }
      if ($biserver::db_jackrabbit_user == 'default') {
        $db_jackrabbit_user = "jcr_user_${biserver::repository_db_shared_suffix}"
      }
       else {
        $db_jackrabbit_user = "${biserver::db_jackrabbit_user}_${biserver::repository_db_shared_suffix}"
      }
      if ($biserver::db_jackrabbit_password == 'default') {
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
  # to configure the BI Server EE
  case $biserver::repository_db_type {
    "postgresql": {
      $repository_db_validation_query = "select 1"
      $repository_db_jdbc_driver = "org.postgresql.Driver"
      $repository_db_jdbc_url_prefix = "jdbc:postgresql://${biserver::repository_db_ipaddress}:${biserver::repository_db_port}/"
      $hibernate_cfg_file = "postgresql.hibernate.cfg.xml"
      $audit_sql = "INSERT INTO PRO_AUDIT (AUDIT_ID, JOB_ID, INST_ID, OBJ_ID, OBJ_TYPE, ACTOR,MESSAGE_TYPE, MESSAGE_NAME, MESSAGE_TEXT_VALUE, MESSAGE_NUM_VALUE, DURATION,AUDIT_TIME) values (NEXTVAL('hibernate_sequence'),?,?,?,?,?,?,?,?,?,?,?)"
      $quartz_driver_delegate_class = "org.quartz.impl.jdbcjobstore.PostgreSQLDelegate"
      $jackrabbit_schema_type = "schema"
      $jackrabbit_schema = 'postgresql'
      $jackrabbit_databasetype = 'postgresql'
      $jackrabbit_persistence_manager_class = 'org.apache.jackrabbit.core.persistence.bundle.PostgreSQLPersistenceManager'
      $jackrabbit_filesystem_class = 'org.apache.jackrabbit.core.fs.db.DbFileSystem'
      $liquibase_database = 'liquibase'
      $quartz_db = "quartz_${biserver::repository_db_shared_suffix}"
      $jackrabbit_db = "jackrabbit_${biserver::repository_db_shared_suffix}"
      $hibernate_db = "hibernate_${biserver::repository_db_shared_suffix}"      
      $pentaho_operations_mart_db = "hibernate_${biserver::repository_db_shared_suffix}"
      $db_pentahomart_user = $db_hibernate_user
      $db_pentahomart_password = $db_hibernate_password
      $split_statements = 'true'
      $sql_transaction = 'false'
    }
    
    "mssql": {
      $repository_db_validation_query = "select 1"
      $repository_db_jdbc_driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
      $repository_db_jdbc_url_prefix = "jdbc:sqlserver://${biserver::repository_db_ipaddress}:${biserver::repository_db_port};databasename="
      $hibernate_cfg_file = "mssql.hibernate.cfg.xml"
      $audit_sql = "INSERT INTO PRO_AUDIT (JOB_ID, INST_ID, OBJ_ID, OBJ_TYPE, ACTOR, MESSAGE_TYPE, MESSAGE_NAME, MESSAGE_TEXT_VALUE, MESSAGE_NUM_VALUE, DURATION, AUDIT_TIME) values (?,?,?,?,?,?,?,?,?,?,?)"
      $quartz_driver_delegate_class = "org.quartz.impl.jdbcjobstore.MSSQLDelegate"
      $jackrabbit_schema_type = "schema"
      $jackrabbit_schema = 'mssql'
      $jackrabbit_databasetype = 'mssql'
      $jackrabbit_persistence_manager_class = 'org.apache.jackrabbit.core.persistence.bundle.MSSqlPersistenceManager'
      $jackrabbit_filesystem_class = 'org.apache.jackrabbit.core.fs.db.MSSqlFileSystem'
      $liquibase_database = 'liquibase'
      $quartz_db = "quartz_${biserver::repository_db_shared_suffix}"
      $jackrabbit_db = "jackrabbit_${biserver::repository_db_shared_suffix}"
      $hibernate_db = "hibernate_${biserver::repository_db_shared_suffix}"      
      $pentaho_operations_mart_db = "hibernate_${biserver::repository_db_shared_suffix}"
      $db_pentahomart_user = $db_hibernate_user
      $db_pentahomart_password = $db_hibernate_password
      $split_statements = 'false'
      $sql_transaction = 'true'
    }
    
    "mysql": {
      $repository_db_validation_query = "select 1 from dual"
      $repository_db_jdbc_driver = "com.mysql.jdbc.Driver"
      $repository_db_jdbc_url_prefix = "jdbc:mysql://${biserver::repository_db_ipaddress}:${biserver::repository_db_port}/"
      $hibernate_cfg_file = "mysql.hibernate.cfg.xml"
      $audit_sql = "INSERT INTO PRO_AUDIT (JOB_ID, INST_ID, OBJ_ID, OBJ_TYPE, ACTOR, MESSAGE_TYPE, MESSAGE_NAME, MESSAGE_TEXT_VALUE, MESSAGE_NUM_VALUE, DURATION, AUDIT_TIME) values (?,?,?,?,?,?,?,?,?,?,?)"
      $quartz_driver_delegate_class = "org.quartz.impl.jdbcjobstore.StdJDBCDelegate"
      $jackrabbit_schema_type = "schema"
      $jackrabbit_schema = 'mysql'
      $jackrabbit_databasetype = 'mysql'
      $jackrabbit_persistence_manager_class = 'org.apache.jackrabbit.core.persistence.bundle.MySqlPersistenceManager'
      $jackrabbit_filesystem_class = 'org.apache.jackrabbit.core.fs.db.DbFileSystem'
      $liquibase_database = 'liquibase'
      $quartz_db = "quartz_${biserver::repository_db_shared_suffix}"
      $jackrabbit_db = "jackrabbit_${biserver::repository_db_shared_suffix}"
      $hibernate_db = "hibernate_${biserver::repository_db_shared_suffix}"
      $pentaho_operations_mart_db = "biserver_operations_mart_${biserver::repository_db_shared_suffix}"
      $db_pentahomart_user = $db_hibernate_user
      $db_pentahomart_password = $db_hibernate_password
      $split_statements = 'true'
      $sql_transaction = 'false'
    }
    
    "oracle": {
      $repository_db_validation_query = "select 1 from dual"
      $repository_db_jdbc_driver = "oracle.jdbc.OracleDriver"
      $repository_db_jdbc_url_prefix = "jdbc:oracle:thin:@${biserver::repository_db_ipaddress}:${biserver::repository_db_port}:"
      $hibernate_cfg_file = "oracle.hibernate.cfg.xml"
      $audit_sql = "INSERT INTO PRO_AUDIT (AUDIT_ID, JOB_ID, INST_ID, OBJ_ID, OBJ_TYPE, ACTOR, MESSAGE_TYPE, MESSAGE_NAME, MESSAGE_TEXT_VALUE, MESSAGE_NUM_VALUE, DURATION, AUDIT_TIME) values (HIBERNATE_SEQUENCE.nextval,?,?,?,?,?,?,?,?,?,?,?)"
      $quartz_driver_delegate_class = "org.quartz.impl.jdbcjobstore.oracle.OracleDelegate"
      $jackrabbit_schema_type = "tablespace"
      $jackrabbit_schema = "pentaho_tablespace_${biserver::repository_db_shared_suffix}"
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
  file { "$biserver::root_dir/biserver-ee/data/$biserver::repository_db_type":
    ensure => "directory"
  }
  
  # Begin importing files to configure the BI Server EE  
  file { "$biserver::root_dir/biserver-ee/tomcat/webapps/pentaho/META-INF/context.xml":
    ensure => "file",
    content => template("biserver/5.3/tomcat6/webapps/pentaho/META-INF/context.xml.erb")
  }
  
  file { "$biserver::root_dir/biserver-ee/pentaho-solutions/system/audit_sql.xml":
    ensure => "file",
    content => template("biserver/5.3/pentaho-solutions/system/audit_sql.xml.erb")
  }
  
  file { "$biserver::root_dir/biserver-ee/pentaho-solutions/system/hibernate/hibernate-settings.xml":
    ensure => "file",
    content => template("biserver/5.3/pentaho-solutions/system/hibernate/hibernate-settings.xml.erb")
  }
  
  file { "$biserver::root_dir/biserver-ee/pentaho-solutions/system/hibernate/${biserver::repository_db_type}.hibernate.cfg.xml":
    ensure => "file",
    content => template("biserver/5.3/pentaho-solutions/system/hibernate/${biserver::repository_db_type}.hibernate.cfg.xml.erb")
  }
  
  file { "$biserver::root_dir/biserver-ee/pentaho-solutions/system/jackrabbit/repository.xml":
    ensure => "file",
    content => template("biserver/5.3/pentaho-solutions/system/jackrabbit/repository.xml.erb")
  }

  file { "$biserver::root_dir/biserver-ee/pentaho-solutions/system/quartz/quartz.properties":
    ensure => "file",
    content => template("biserver/5.3/pentaho-solutions/system/quartz/quartz.properties.erb")
  }

  # SQL Order of Execution:
  # 1) Create Databases
  # 2) Create Permissions
  # 3 asynchronous) Create Quartz
  # 3 asynchronous) Create Pentaho Mart
  
  
  # Repository deployment is done using Liquibase (http://www.liquibase.org/)
  # As such EVERY repository RDBMS MUST have a database for writing update records to
  database_schema::liquibase { "${biserver::repository_db_type}_create_databases - ${biserver::repository_db_shared_suffix}":
    db_username   => $biserver::repository_db_user,
    db_password   => $biserver::repository_db_password,
    jdbc_url      => "${repository_db_jdbc_url_prefix}${liquibase_database}",
    changeset_id  => "${biserver::repository_db_type}_create_databases",
    sqlstatement  => template("biserver/5.3/data/${biserver::repository_db_type}/${biserver::repository_db_type}_create_databases.sql.erb"),
    sql_transaction => "$sql_transaction",
    split_statements => $split_statements
  }
  
  database_schema::liquibase { "${biserver::repository_db_type}_create_permissions - ${biserver::repository_db_shared_suffix}":
    db_username   => $biserver::repository_db_user,
    db_password   => $biserver::repository_db_password,
    jdbc_url      => "${repository_db_jdbc_url_prefix}${liquibase_database}",
    changeset_id  => "${biserver::repository_db_type}_create_permissions",
    sqlstatement  => template("biserver/5.3/data/${biserver::repository_db_type}/${biserver::repository_db_type}_create_permissions.sql.erb"),
    sql_transaction => "$sql_transaction",
    split_statements => $split_statements,
    require => Database_schema::Liquibase["${biserver::repository_db_type}_create_databases - ${biserver::repository_db_shared_suffix}"]
  }
  
  database_schema::liquibase { "${biserver::repository_db_type}_create_quartz - ${biserver::repository_db_shared_suffix}":
    db_username   => $db_quartz_user,
    db_password   => $db_quartz_password,
    jdbc_url      => "${repository_db_jdbc_url_prefix}${quartz_db}",
    changeset_id  => "${biserver::repository_db_type}_create_quartz",
    sqlstatement  => template("biserver/5.3/data/${biserver::repository_db_type}/${biserver::repository_db_type}_create_quartz.sql.erb"),
    split_statements => true,
    require       => Database_schema::Liquibase["${biserver::repository_db_type}_create_permissions - ${biserver::repository_db_shared_suffix}"]
  }
  
  database_schema::liquibase { "${biserver::repository_db_type}_create_pentahomart - ${biserver::repository_db_shared_suffix}":
    db_username   => $db_pentahomart_user,
    db_password   => $db_pentahomart_password,
    jdbc_url      => "${repository_db_jdbc_url_prefix}${pentaho_operations_mart_db}",
    changeset_id  => "${biserver::repository_db_type}_create_pentahomart",
    sqlstatement  => template("biserver/5.3/data/${biserver::repository_db_type}/${biserver::repository_db_type}_create_pentahomart.sql.erb"),
    split_statements => true,
    require       => Database_schema::Liquibase["${biserver::repository_db_type}_create_permissions - ${biserver::repository_db_shared_suffix}"]
  }
}
