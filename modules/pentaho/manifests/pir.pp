# Class to install Pentaho Interactive Reporting (BI Server EE plugin)
class pentaho::pir (
) {
  class {"pentaho::pir::download": }
  
  class {"pentaho::pir::install":
    subscribe => Class["pentaho::pir::download"]
  }
  
  class {"pentaho::pir::cleanup":
    require => Class["pentaho::pir::install"]
  }
  
  class {"pentaho::pir::configure":
    require => Class["pentaho::pir::install"]
  }
}

# Fetch the -dist archive then extract the installer
class pentaho::pir::download (
  $installer_root_dir = "$pentaho::installer_root_dir"
) {
  staging::file { "$pentaho::source_pir_file":
    source => "$pentaho::source_host/$pentaho::source_path/$pentaho::source_pir_file"
  }
  
  file { ["$installer_root_dir/pir-plugin"]:
    ensure => directory
  }
  
  staging::extract { $pentaho::source_pir_file:
    target => "$installer_root_dir/pir-plugin",
    flatten => true,
    require => [ File["$installer_root_dir/pir-plugin"],
	             Staging::File["$pentaho::source_pir_file"] ]
  }
}

# Execute the -dist installer to extract the plugin
class pentaho::pir::install (
  $installer_dir = "$pentaho::installer_root_dir/pir-plugin",
  $root_dir = "$pentaho::root_dir",
  $biserver_ee_dir   = "$pentaho::biserver_ee_dir"
) {
  $automated_install_file_content = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
<AutomatedInstallation langpack=\"eng\">
  <com.pentaho.engops.eula.izpack.PentahoHTMLLicencePanel id=\"licensepanel\"/>
  <com.izforge.izpack.panels.target.TargetPanel id=\"targetpanel\">
  <installpath>$root_dir/$biserver_ee_dir/pentaho-solutions/system</installpath>
  </com.izforge.izpack.panels.target.TargetPanel>
  <com.izforge.izpack.panels.install.InstallPanel id=\"installpanel\"/>
</AutomatedInstallation>"

  file { "$installer_dir/automated_install.xml":
    ensure => file,
    content => $automated_install_file_content,
    require => File["$installer_dir"]
  }

  exec { "Extract pir Plugin" :
    command => "java -jar installer.jar $installer_dir/automated_install.xml",
    cwd => "$installer_dir",
    path => ["$java::java_directory/bin"],
    require => [ Staging::Extract["$pentaho::source_pir_file"],
	             File["$installer_dir/automated_install.xml"] ],
    subscribe => File["$root_dir/$biserver_ee_dir/pentaho-solutions/system"]
  }
}

# Remove the installer files
class pentaho::pir::cleanup (
  $installer_dir = "$pentaho::installer_root_dir/pir-plugin"
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

class pentaho::pir::configure {
}
