class java::params {
  $type    = "jdk"
  $version = "7u75"
  
  $java_archive_source = "http://10.177.176.213/engops/java"

  if ($::kernel == 'windows') {
    $install_directory = "c:\\opt"
    $archive_type = "zip"
  } elsif ($::kernel == "Darwin") {
    $install_directory = "/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents"
    $archive_type = "tar.gz"
  } else {
    $install_directory = "/opt"
    $archive_type = "tar.gz"
  }
}
