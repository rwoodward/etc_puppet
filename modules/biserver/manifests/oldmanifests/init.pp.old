# Class: pentaho
#
# This module manages all Pentaho products and their available plugins
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

class pentaho (
  $ensure                       = "present",
  $installer_root_dir           = "$pentaho::params::root_dir/installers",
  $suite_version                = "$pentaho::params::suite_version",
  $root_dir                     = "$pentaho::params::root_dir",
  $license_installer_path       = "$pentaho::params::license_installer_path",
  $license_files_path           = "$pentaho::params::license_files_path",
  $source_host                  = "$pentaho::params::source_host",
  $source_path                  = "$pentaho::params::source_path",
  $install_biserver_ee          = "$pentaho::params::install_biserver_ee",
  $source_biserver_file         = "$pentaho::params::source_biserver_file",
  $biserver_platform            = "$pentaho::params::biserver_platform",
  $source_biserver_platform_url = "$pentaho::params::source_biserver_platform_url",
  $db_hibernate_user            = "$pentaho::params::db_hibernate_user",
  $db_hibernate_password        = "$pentaho::params::db_hibernate_password",
  $db_quartz_user               = "$pentaho::params::db_quartz_user",
  $db_quartz_password           = "$pentaho::params::db_quartz_password",
  $db_jackrabbit_user           = "$pentaho::params::db_jackrabbit_user",
  $db_jackrabbit_password       = "$pentaho::params::db_jackrabbit_password",
  $bis_host                     = "$pentaho::params::bis_host",
  $bis_port                     = "$pentaho::params::bis_port",
  $bis_webapp_name              = "$pentaho::params::bis_webapp_name",
  $install_paz_plugin           = "$pentaho::params::install_paz_plugin",
  $source_paz_file              = "$pentaho::params::source_paz_file",
  $install_pdd_plugin           = "$pentaho::params::install_pdd_plugin",
  $source_pdd_file              = "$pentaho::params::source_pdd_file",
  $install_pir_plugin           = "$pentaho::params::install_pir_plugin",
  $source_pir_file              = "$pentaho::params::source_pir_file",
  $repository_db_type           = "$pentaho::params::repository_db_type",
  $repository_db_version        = "$pentaho::params::repository_db_version",
  $repository_db_ipaddress      = "$pentaho::params::repository_db_ipaddress",
  $repository_db_port           = "$pentaho::params::repository_db_port",
  $repository_db_user           = "$pentaho::params::repository_db_user",
  $repository_db_password       = "$pentaho::params::repository_db_password",
  $repository_db_shared_suffix  = "$pentaho::params::repository_db_shared_suffix",
  $javatype			= "$pentaho::params::javatype",
  $javaversion			= "$pentaho::params::javaversion"
) inherits pentaho::params {
  # Install Java - Set appropriate version based on Pentaho product as necessary
  if !defined(Class[java]) {
    class { "java":
	type => "$javatype",
	version => "$javaversion",
    }
  }
  
  # Set state that is common to ALL Pentaho products
  class {'pentaho::shared_resources':
    require => Class["java"]
  }
  
  # Install the BI Server if configured
  if ($pentaho::install_biserver_ee == 'true') {
    class {'pentaho::biserver_ee': 
	    require => Class["pentaho::shared_resources"]
  	}
	
	  # Install the Pentaho Analyzer Plugin if configured, and BI Server EE is installed
		if ($pentaho::install_paz_plugin == 'true') {
	  	class {'pentaho::paz':
		    require => [ Class["pentaho::shared_resources"],
		             	Class["pentaho::biserver_ee"] ]
	  	}
		}
	
  	# Install the Pentaho Dashboard Designer Plugin if configured, and BI Server EE is installed
		if ($pentaho::install_pdd_plugin == 'true') {
		  class {'pentaho::pdd':
		    require => [ Class["pentaho::shared_resources"],
			             Class["pentaho::biserver_ee"] ]
	  	}
		}
	
  	# Install the Pentaho Interactive Reporting Plugin if configured, and BI Server EE is installed
		if ($pentaho::install_pir_plugin == 'true') {
		  class {'pentaho::pir':
	    	require => [ Class["pentaho::shared_resources"],
		             	Class["pentaho::biserver_ee"] ]
	  	}
		}
  }
}
