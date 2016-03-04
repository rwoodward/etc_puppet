# manage /etc/hosts file
class etc-hosts ($ips=[$ipaddress], $fullhosts=[$fqdn], $hosts=[$hostname], $numhosts='1') {

$maxindex = $numhosts - 1

  file { '/etc/hosts':
    content => template('etc-hosts/etc.hosts.erb'),
    owner => 'root',
    group => 'root',
    mode => '0644',
  }
}
