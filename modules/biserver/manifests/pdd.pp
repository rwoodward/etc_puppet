# Class to install Pentaho Dashboard Designer (BI Server EE plugin)
class biserver::pdd (
) {
  class {"biserver::pdd::download": }
  
  class {"biserver::pdd::install":
    subscribe => Class["biserver::pdd::download"]
  }
  
  class {"biserver::pdd::cleanup":
    require => Class["biserver::pdd::install"]
  }
  
  class {"biserver::pdd::configure":
    require => Class["biserver::pdd::install"]
  }
}

# Fetch the -dist archive then extract the installer
class biserver::pdd::download (
  $installer_root_dir = "$biserver::installer_root_dir"
) {
  staging::file { "$biserver::source_pdd_file":
    source => "$biserver::source_host/$biserver::source_path/$biserver::source_pdd_file"
  }
  
  file { ["$installer_root_dir/pdd-plugin"]:
    ensure => directory
  }
  
  staging::extract { $biserver::source_pdd_file:
    target => "$installer_root_dir/pdd-plugin",
    flatten => true,
    require => [ File["$installer_root_dir/pdd-plugin"],
	             Staging::File["$biserver::source_pdd_file"] ]
  }
}

# Execute the -dist installer to extract the plugin
class biserver::pdd::install (
  $installer_dir = "$biserver::installer_root_dir/pdd-plugin",
  $biserver_ee_dir   = "$biserver::root_dir/biserver-ee" 
) {
  $automated_install_file_content = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
<AutomatedInstallation langpack=\"eng\">
  <com.pentaho.engops.eula.izpack.PentahoHTMLLicencePanel id=\"licensepanel\"/>
  <com.izforge.izpack.panels.target.TargetPanel id=\"targetpanel\">
  <installpath>$biserver_ee_dir/pentaho-solutions/system</installpath>
  </com.izforge.izpack.panels.target.TargetPanel>
  <com.izforge.izpack.panels.install.InstallPanel id=\"installpanel\"/>
</AutomatedInstallation>"

  file { "$installer_dir/automated_install.xml":
    ensure => file,
    content => $automated_install_file_content,
    require => File["$installer_dir"]
  }

  exec { "Extract pdd Plugin" :
    command => "java -jar installer.jar $installer_dir/automated_install.xml",
    cwd => "$installer_dir",
    path => ["$java::java_directory/bin"],
    require => [ Staging::Extract["$biserver::source_pdd_file"],
	             File["$installer_dir/automated_install.xml"] ],
    subscribe => File["$biserver_ee_dir/pentaho-solutions/system"]
  }
}

# Remove the installer files
class biserver::pdd::cleanup (
  $installer_dir = "$biserver::installer_root_dir/pdd-plugin"
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

class biserver::pdd::configure {
}
