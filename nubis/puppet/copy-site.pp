# Copy status page to Apache web root

file {'/var/www/html/200.html':
  ensure => file,
  owner  => root,
  group  => root,
  mode   => '0755',
  source => 'puppet:///nubis/files/200.html',
}
