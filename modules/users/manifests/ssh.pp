# manage user ssh credentials
define users::ssh ( $path ) {

  $username = $name

  file { "${path}/.ssh":
    ensure => "directory",
    owner => "${username}",
    group => "${username}",
    mode => 700,
  }

  ssh_authorized_key {"${username}":
    user => "${username}",
    type => 'rsa',
    key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA1RQSDLMiYNbN0KjG1/23EtiUHPpNZAuw8Rgi/gwVQw3yfaNwSzo3blRUH7/9wLWEGO7RZQSXx5/O3HkbKnwFYp3qjxtnWMFORpB7mpEqVoF9y9hVyPM35FniYj8zA37+eGAz6kp+xC3PYq2+/Q/z+cwHdFWQQpkR8plXa0wLHSo0PtY+xJe3SHuiK332ZubvbaMH7Sog8ikZ4qaD8lQBDBR9U+0/aPw9woeJuXBMxrJZUi/widGCUHuj9hwS7kdoKWuKhKgFJWYjthj1NHqSHd9zUAu3uiOxWw+I95+zMzIdVAkO8skOObnhcBVnffr6IZGsBu9c/REg/emLSKG0Hw==',
    require => File["${path}/.ssh"],
  }

  file {"${path}/.ssh/id_rsa":
    source => 'puppet:///modules/users/id_rsa',
    owner => "${username}",
    group => "${username}",
    mode => '0600',
    require => File["${path}/.ssh"],
  }

  file {"${path}/.ssh/id_rsa.pub":
    source => 'puppet:///modules/users/id_rsa.pub',
    owner => "${username}",
    group => "${username}",
    mode => '0644',
    require => File["${path}/.ssh"],
  }
}
