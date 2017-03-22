# Ensure that php5-ldap is installed

package { 'php5-ldap':
    ensure => present,
    name   =>  'php5-ldap'
}

package { 'libldap':
    ensure => present,
    name   => 'libldap'
}

package { 'openldap':
    ensure => present,
    name   => 'openldap'
}
