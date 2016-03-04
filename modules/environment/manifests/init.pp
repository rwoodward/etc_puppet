# manage environmental variables and path settings

class environment(
    $java_home = "/opt/jdk1.7.0_75")
    {

    require java

    exec {'install java':
        cwd => $java_home,
        logoutput => true,
        command => "/usr/sbin/alternatives --install /usr/bin/java java ${java_home}/bin/java 1",
    }

    exec {'set java':
        cwd => $java_home,
        logoutput => true,
        command => "/usr/sbin/alternatives --set java ${java_home}/bin/java",
    }

    file { "/etc/environment":
        content => inline_template("JAVA_HOME=$java_home"),
    }

}
