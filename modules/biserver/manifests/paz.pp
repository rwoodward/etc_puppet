# Class to install Pentaho Analyzer (BI Server EE plugin)
class biserver::paz (
) {
  class {"biserver::paz::download": }
  
  class {"biserver::paz::install":
    subscribe => Class["biserver::paz::download"]
  }
  
  class {"biserver::paz::cleanup":
    require => Class["biserver::paz::install"]
  }
  
  class {"biserver::paz::configure":
    require => Class["biserver::paz::install"]
  }
}

# Fetch the -dist archive then extract the installer
class biserver::paz::download (
  $installer_root_dir = "$biserver::installer_root_dir"
) {
  staging::file { "$biserver::source_paz_file":
    source => "$biserver::source_host/$biserver::source_path/$biserver::source_paz_file"
  }
  
  file { ["$installer_root_dir/paz-plugin"]:
    ensure => directory
  }
  
  staging::extract { $biserver::source_paz_file:
    target => "$installer_root_dir/paz-plugin",
    flatten => true,
    require => [ File["$installer_root_dir/paz-plugin"],
	             Staging::File["$biserver::source_paz_file"] ]
  }
}

# Execute the -dist installer to extract the plugin
class biserver::paz::install (
  $installer_dir = "$biserver::installer_root_dir/paz-plugin",
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

  exec { "Extract PAZ Plugin" :
    command => "java -jar installer.jar $installer_dir/automated_install.xml",
    cwd => "$installer_dir",
    path => ["$java::java_directory/bin"],
    require => [ Staging::Extract["$biserver::source_paz_file"],
	             File["$installer_dir/automated_install.xml"] ],
	subscribe => File["$biserver_ee_dir/pentaho-solutions/system"]
  }
}

# Remove the installer files
class biserver::paz::cleanup (
  $installer_dir = "$biserver::installer_root_dir/paz-plugin"
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

class biserver::paz::configure {
}
