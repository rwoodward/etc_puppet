# manage mysql required sql files
class mysql-files {

  file {'/root/mysql-files':
    ensure => 'directory',
    owner => 'root',
    group => 'root',
    mode => '0644',
  }

  file {'/root/mysql-files/mysql.sql':
    source => 'puppet:///modules/mysql-files/mysql.sql',
    owner => 'root',
    group => 'root',
    mode => '0644',
    require => File['/root/mysql-files'],
  }

  file {'/root/mysql-files/aggregatehdfs.txt':
    source => 'puppet:///modules/mysql-files/aggregatehdfs.txt',
    owner => 'root',
    group => 'root',
    mode => '0644',
    require => File['/root/mysql-files'],
  }

  file {'/root/mysql-files/aggregate_hbase.txt':
    source => 'puppet:///modules/mysql-files/aggregate_hbase.txt',
    owner => 'root',
    group => 'root',
    mode => '0644',
    require => File['/root/mysql-files'],
  }

  file {'/root/mysql-files/aggregate_hive.txt':
    source => 'puppet:///modules/mysql-files/aggregate_hive.txt',
    owner => 'root',
    group => 'root',
    mode => '0644',
    require => File['/root/mysql-files'],
  }
}
