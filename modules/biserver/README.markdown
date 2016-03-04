# Biserver Puppet Module #

Welcome to the Biserver Puppet module. Using the Biserver module you can install Pentaho
products of supported versions with various configurations.

### Supported Product Matrix ###
* Version 5.3
  * BI Server EE
  * Pentaho Analyzer
  * Pentaho Dashboard Designer
  * Pentaho Interactive Reporting
  
### Usage ###
#### Parameters: ####
* suite\_version
  * 5.3
> Version of the Pentaho Suite to install

* install\_biserver\_ee
  * true
  * false
> Enable the installation of the Pentaho Enterprise BA Server

* install\_paz\_plugin
  * true
  * false
> Enable the installation of the Pentaho Enterprise Analyzer BA Server plugin

* install\_pdd\_plugin
  * true
  * false
> Enable the installation of the Pentaho Enterprise Dashboard Designer BA Server plugin

* install\_pir\_plugin
  * true
  * false
> Enable the installation of the Pentaho Enterprise Interactive Reporting BA Server plugin
