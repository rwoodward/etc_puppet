# Class: database_schema
#
# This module manages database_schema
#
class database_schema (
) {

#  class {'database_schema::liquibase' :
#    db_username   => root,
#    db_password   => pentahoqa,
#    jdbc_url      => 'jdbc:mysql://10.177.176.203/test',
#    changeset_id  => "create_mysql_jcr",
#    sqlstatement  => "DROP DATABASE IF EXISTS `awesome_sauce`;\n
#                      CREATE DATABASE IF NOT EXISTS `awesome_sauce` DEFAULT CHARACTER SET utf8;\n
#                      GRANT ALL ON awesome_sauce.* TO 'capt_awez'@'%' IDENTIFIED BY 'snazu';\n"
#  }
}
