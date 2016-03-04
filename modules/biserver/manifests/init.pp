# Class: biserver
#
# This module manages the Pentaho BAServer product and the available plugins
#
# GENERAL NOTES:
# This module WILL install a JDK applicable to the version of Pentaho to be installed.
# This module WILL install 7-Zip on Windows machines.
# Database for Repository MUST be installed and configured before hand.
#
# Presently supported configurations:
# BI Server EE on Tomcat 6
# Postgres Repository
# MySQL Repository
# MS Sql Server Repository
# Oracle Repository

class biserver (
  $ensure                       = "present",
  $installer_root_dir           = "$biserver::params::root_dir/installers",
  $suite_version                = "$biserver::params::suite_version",
  $root_dir                     = "$biserver::params::root_dir",
  $license_installer_path       = "$biserver::params::license_installer_path",
  $license_files_path           = "$biserver::params::license_files_path",
  $source_host                  = "$biserver::params::source_host",
  $source_path                  = "$biserver::params::source_path",
  $install_biserver_ee          = "$biserver::params::install_biserver_ee",
  $source_biserver_file         = "$biserver::params::source_biserver_file",
  $biserver_platform            = "$biserver::params::biserver_platform",
  $source_biserver_platform_url = "$biserver::params::source_biserver_platform_url",
  $db_hibernate_user            = "$biserver::params::db_hibernate_user",
  $db_hibernate_password        = "$biserver::params::db_hibernate_password",
  $db_quartz_user               = "$biserver::params::db_quartz_user",
  $db_quartz_password           = "$biserver::params::db_quartz_password",
  $db_jackrabbit_user           = "$biserver::params::db_jackrabbit_user",
  $db_jackrabbit_password       = "$biserver::params::db_jackrabbit_password",
  $bis_host                     = "$biserver::params::bis_host",
  $bis_port                     = "$biserver::params::bis_port",
  $bis_webapp_name              = "$biserver::params::bis_webapp_name",
  $install_paz_plugin           = "$biserver::params::install_paz_plugin",
  $source_paz_file              = "$biserver::params::source_paz_file",
  $install_pdd_plugin           = "$biserver::params::install_pdd_plugin",
  $source_pdd_file              = "$biserver::params::source_pdd_file",
  $install_pir_plugin           = "$biserver::params::install_pir_plugin",
  $source_pir_file              = "$biserver::params::source_pir_file",
  $repository_db_type           = "$biserver::params::repository_db_type",
  $repository_db_version        = "$biserver::params::repository_db_version",
  $repository_db_ipaddress      = "$biserver::params::repository_db_ipaddress",
  $repository_db_port           = "$biserver::params::repository_db_port",
  $repository_db_user           = "$biserver::params::repository_db_user",
  $repository_db_password       = "$biserver::params::repository_db_password",
  $repository_db_shared_suffix  = "$biserver::params::repository_db_shared_suffix",
  $javatype			= "$java::params::type",
  $javaversion			= "$java::params::version"
) inherits biserver::params {
  # Install Java - Set appropriate version based on Pentaho product as necessary
#  if !defined(Class[java]) {
#    class { "java":
#	type => "$javatype",
#	version => "$javaversion",
#    }
#  }
  
  # Set state that is common to ALL Pentaho products
  class {'biserver::shared_resources':
#    require => Class["java"]
  }
 
require java
 
  # Install the BI Server if configured
  if ($biserver::install_biserver_ee == 'true') {
    class {'biserver::biserver_ee': 
	    require => Class["biserver::shared_resources"]
  	}
	
	  # Install the Pentaho Analyzer Plugin if configured, and BI Server EE is installed
		if ($biserver::install_paz_plugin == 'true') {
	  	class {'biserver::paz':
		    require => [ Class["biserver::shared_resources"],
		             	Class["biserver::biserver_ee"] ]
	  	}
		}
	
  	# Install the Pentaho Dashboard Designer Plugin if configured, and BI Server EE is installed
		if ($biserver::install_pdd_plugin == 'true') {
		  class {'biserver::pdd':
		    require => [ Class["biserver::shared_resources"],
			             Class["biserver::biserver_ee"] ]
	  	}
		}
	
  	# Install the Pentaho Interactive Reporting Plugin if configured, and BI Server EE is installed
		if ($biserver::install_pir_plugin == 'true') {
		  class {'biserver::pir':
	    	require => [ Class["biserver::shared_resources"],
		             	Class["biserver::biserver_ee"] ]
	  	}
		}
  }
}
