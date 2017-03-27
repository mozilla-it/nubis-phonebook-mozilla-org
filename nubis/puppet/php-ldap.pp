# Ensure that php5-ldap is installed

package { 'php5-ldap':
    ensure => present,
    name   =>  'php5-ldap'
}

package { 'libldap-2.4-2':
    ensure => present,
    name   => 'libldap-2.4-2'
}

package { 'libldap2-dev':
    ensure => present,
    name   => 'libldap2-dev'
}

package { 'shelldap':
    ensure => present,
    name   => 'shelldap'
}

package { 'ldap-utils':
    ensure => present,
    name   => 'ldap-utils'
}

package { 'php5-gd':
    ensure => present,
    name   => 'php5-gd'
}

file { '/etc/certs':
    ensure => directory,
}

file { '/etc/ldap/ldap.conf':
    ensure => present,
    source => 'puppet:///nubis/files/ldap.conf',
}
