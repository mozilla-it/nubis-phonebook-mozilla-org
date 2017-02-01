# Copy index page to Apache web root

file {'/var/www/html/index.htm':
	ensure => file,
	owner	 => root,
	group  => root,
	mode   => '0755',
	source => 'puppet:///nubis/files/index.htm',
}
