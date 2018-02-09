# Ensure that php-ldap is installed

package { 'php-ldap':
    ensure => present,
}

package { 'libldap-2.4-2':
    ensure => present,
}

package { 'libldap2-dev':
    ensure => present,
}

package { 'shelldap':
    ensure => present,
}

package { 'ldap-utils':
    ensure => present,
}

package { 'php-gd':
    ensure => present,
}

file { '/etc/certs':
    ensure => directory,
}

file { '/etc/ldap/ldap.conf':
    ensure => present,
    source => 'puppet:///nubis/files/ldap.conf',
}
