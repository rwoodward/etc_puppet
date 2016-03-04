# Class: diserver
#
# This module manages installation of the Pentaho Data Integration Server
#
#
# GENERAL NOTES:
# This module WILL install a JDK applicable to the version of Pentaho to be installed.
# This module WILL install 7-Zip on Windows machines.
# Database for Repository MUST be installed and configured before hand.
#
# Presently supported configurations:
# DI Server EE on Tomcat 7 & 8, and JBoss
# Postgres Repository
# MySQL Repository
# MS Sql Server Repository
# Oracle Repository

class diserver (
  $ensure                       = "present",
  $installer_root_dir           = "$diserver::params::root_sub_dir/installers",
  $suite_version                = "$diserver::params::suite_version",
  $root_dir                     = "$diserver::params::root_dir",
  $license_installer_path       = "$diserver::params::license_installer_path",
  $license_files_path           = "$diserver::params::license_files_path",
  $source_host                  = "$diserver::params::source_host",
  $source_path                  = "$diserver::params::source_path",
  $install_diserver_ee          = "$diserver::params::install_diserver_ee",
  $source_diserver_file         = "$diserver::params::source_diserver_file",
  $diserver_platform            = "$diserver::params::diserver_platform",
  $source_diserver_platform_url = "$diserver::params::source_diserver_platform_url",
  $db_hibernate_user            = "$diserver::params::db_hibernate_user",
  $db_hibernate_password        = "$diserver::params::db_hibernate_password",
  $db_quartz_user               = "$diserver::params::db_quartz_user",
  $db_quartz_password           = "$diserver::params::db_quartz_password",
  $db_jackrabbit_user           = "$diserver::params::db_jackrabbit_user",
  $db_jackrabbit_password       = "$diserver::params::db_jackrabbit_password",
  $dis_host                     = "$diserver::params::dis_host",
  $dis_port                     = "$diserver::params::dis_port",
  $dis_webapp_name              = "$diserver::params::dis_webapp_name",
#  $install_paz_plugin           = "$diserver::params::install_paz_plugin",
#  $source_paz_file              = "$diserver::params::source_paz_file",
#  $install_pdd_plugin           = "$diserver::params::install_pdd_plugin",
#  $source_pdd_file              = "$diserver::params::source_pdd_file",
#  $install_pir_plugin           = "$diserver::params::install_pir_plugin",
#  $source_pir_file              = "$diserver::params::source_pir_file",
  $repository_db_type           = "$diserver::params::repository_db_type",
  $repository_db_version        = "$diserver::params::repository_db_version",
  $repository_db_ipaddress      = "$diserver::params::repository_db_ipaddress",
  $repository_db_port           = "$diserver::params::repository_db_port",
  $repository_db_user           = "$diserver::params::repository_db_user",
  $repository_db_password       = "$diserver::params::repository_db_password",
  $repository_db_shared_suffix  = "$diserver::params::repository_db_shared_suffix",
  $javatype			= "$java::params::type",
  $javaversion			= "$java::params::version",
  $_PENTAHO_JAVA_HOME = $java::java_directory
) inherits diserver::params {

#  New Install Java - diserver class now requires java class

  require java
  
  # Set state that is common to ALL Pentaho products
#  class {'diserver::shared_resources':
#  }
  
  # Install DI Server if configured
  if ($diserver::install_diserver_ee == 'true') {
    class {'diserver::diserver_ee': 
#	    require => Class["diserver::shared_resources"]
    }
  }
}
