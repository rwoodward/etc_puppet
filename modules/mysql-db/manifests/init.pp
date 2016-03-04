# mysql-db class init.pp - front end module for creating multiple mysql dbs
class mysql-db ($resources = {}) {

#  $defaults = {
#    password => 'password',
#    ensure => present,
#    enforce_sql => 'true',
#  }

#  $resources = {
#    'grants' => {
#      user => 'grantsuser',
#      sql => '/root/mysql-files/mysql.sql',
#    },
#    'test' => {
#      user => 'testuser',
#      sql => ['/root/mysql-files/aggregatehdfs.txt','/root/mysql-files/aggregate_hbase.txt','/root/mysql-files/aggregate_hive.txt'],
#    },
#  }

  require mysql-files

  create_resources('mysql::db', $resources)
}
