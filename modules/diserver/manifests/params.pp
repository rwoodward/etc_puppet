class diserver::params {
# -- GENERAL --
  $suite_version          = '5.3'
  if ($::kernel == 'windows') {
    $root_dir               = 'c:\\opt\\pentaho'
    $root_sub_dir           = 'c:\\opt\\pentaho\\server'
  } else {
    $root_dir               = '/opt/pentaho'
    $root_sub_dir           = '/opt/pentaho/server'
  }
  
  $license_installer_path = "${root_dir}/license-installer"
  $license_files_path     = "http://10.177.176.213/engops/licenses"

  $pentpassword           = '$1$FLG3vKSq$7qzf..0ElnjpuGyoXWAAo/' #use: 'openssl passwd -1' to generate this hash
  $architecture           = $::hardwaremodel
  $source_host            = 'http://10.177.176.213'
  $source_path            = 'hosted/5.3.0.0/latest'

# -- BI Server --
  $install_diserver_ee    = 'true'
  $source_diserver_file   = 'pdi-ee-server-dist.zip'
  $diserver_platform      = 'default' # default: source_diserver_file MUST be an archive (NOT a manual deployment) (tomcat6, tomcat7, jboss61, jboss62)
  $source_diserver_platform_url = 'http://resources.diserver.com/platforms/tomcat6.zip'
  $db_hibernate_user      = 'default'
  $db_hibernate_password  = 'default'
  $db_quartz_user         = 'default'
  $db_quartz_password     = 'default'
  $db_jackrabbit_user     = 'default'
  $db_jackrabbit_password = 'default'
  
  $dis_host               = '127.0.0.1'
  $dis_port               = '9080'
  $dis_webapp_name        = 'pentaho-di'
  
# -- PAZ Plugin --
#  $install_paz_plugin     = 'true'
#  $source_paz_file        = 'paz-plugin-ee-dist.zip'
  
# -- PDD Plugin --
#  $install_pdd_plugin     = 'true'
#  $source_pdd_file        = 'pdd-plugin-ee-dist.zip'
  
# -- PIR Plugin --
#  $install_pir_plugin     = 'true'
#  $source_pir_file        = 'pir-plugin-ee-dist.zip'

# -- Java type and version overides --
  $javatype		  = 'jdk'
  $javaversion		  = '7u75'

# -- Repository DB --
#  $repository_db_type             = 'mssql' # default(Ignore ALL repository_db_* settings), mssql, mysql, oracle, postgres
#  $repository_db_version          = '2008'
#  $repository_db_ipaddress        = '10.177.176.132'
#  $repository_db_port             = '1433'
#  $repository_db_user             = 'sa'
#  $repository_db_password         = 'password'

#  $repository_db_type             = 'oracle' # default(Ignore ALL repository_db_* settings), mssql, mysql, oracle, postgres
#  $repository_db_version          = '10g'
#  $repository_db_ipaddress        = '10.177.176.205'
#  $repository_db_port             = '1521'
#  $repository_db_user             = 'system'
#  $repository_db_password         = 'password'


#  $repository_db_type             = 'mysql' # default(Ignore ALL repository_db_* settings), mssql, mysql, oracle, postgres
#  $repository_db_version          = '5.6'
#  $repository_db_ipaddress        = '10.177.176.203'
#  $repository_db_port             = '3306'
#  $repository_db_user             = 'root'
#  $repository_db_password         = 'diserverqa'
  
  $repository_db_type             = 'postgresql' # default(Ignore ALL repository_db_* settings), mssql, mysql, oracle, postgresql
  $repository_db_version          = '9.3'
  $repository_db_ipaddress        = '10.177.176.200'
  $repository_db_port             = '5432'
  $repository_db_user             = 'postgres'
  $repository_db_password         = 'password'

  $repository_db_shared_suffix    = 'bbu' # Uniquely identify instance. Prevents repository DB name collision on shared RDBMS
}
