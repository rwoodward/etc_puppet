# manage user ssh credentials
define users::ssh {

  if $name == 'root' {  

    ssh_authorized_key {'root_ssh':
      user => 'root',
      type => 'rsa',
      key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA1RQSDLMiYNbN0KjG1/23EtiUHPpNZAuw8Rgi/gwVQw3yfaNwSzo3blRUH7/9wLWEGO7RZQSXx5/O3HkbKnwFYp3qjxtnWMFORpB7mpEqVoF9y9hVyPM35FniYj8zA37+eGAz6kp+xC3PYq2+/Q/z+cwHdFWQQpkR8plXa0wLHSo0PtY+xJe3SHuiK332ZubvbaMH7Sog8ikZ4qaD8lQBDBR9U+0/aPw9woeJuXBMxrJZUi/widGCUHuj9hwS7kdoKWuKhKgFJWYjthj1NHqSHd9zUAu3uiOxWw+I95+zMzIdVAkO8skOObnhcBVnffr6IZGsBu9c/REg/emLSKG0Hw==',
    }

    file {'/root/.ssh/id_rsa':
      source => 'puppet:///modules/users/id_rsa',
      owner => 'root',
      group => 'root',
      mode => '0600',
    }

    file {'/root/.ssh/id_rsa.pub':
      source => 'puppet:///modules/users/id_rsa.pub',
      owner => 'root',
      group => 'root',
      mode => '0644',
    }
  }

  else {

    ssh_authorized_key {"$name":
      user => "$name",
      type => 'rsa',
      key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA1RQSDLMiYNbN0KjG1/23EtiUHPpNZAuw8Rgi/gwVQw3yfaNwSzo3blRUH7/9wLWEGO7RZQSXx5/O3HkbKnwFYp3qjxtnWMFORpB7mpEqVoF9y9hVyPM35FniYj8zA37+eGAz6kp+xC3PYq2+/Q/z+cwHdFWQQpkR8plXa0wLHSo0PtY+xJe3SHuiK332ZubvbaMH7Sog8ikZ4qaD8lQBDBR9U+0/aPw9woeJuXBMxrJZUi/widGCUHuj9hwS7kdoKWuKhKgFJWYjthj1NHqSHd9zUAu3uiOxWw+I95+zMzIdVAkO8skOObnhcBVnffr6IZGsBu9c/REg/emLSKG0Hw==',
    }

    file {"/home/$name/.ssh/id_rsa":
      source => 'puppet:///modules/users/id_rsa',
      owner => "$name",
      group => "$name",
      mode => '0600',
    }

    file {"/home/$name/.ssh/id_rsa.pub":
      source => 'puppet:///modules/users/id_rsa.pub',
      owner => "$name",
      group => "$name",
      mode => '0644',
    }
  }
}
