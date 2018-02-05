file { '/etc/confd':
  ensure  => directory,
  recurse => true,
  purge   => false,
  owner   => 'root',
  group   => 'root',
  source  => 'puppet:///nubis/files/confd',
}

include nubis_configuration
nubis::configuration{ $project_name:
  format  => 'php',
}
