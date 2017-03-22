# Ensure that php5-ldap is installed

package { 'php5-ldap':
    ensure => present,
    name   =>  'php5-ldap'
}
