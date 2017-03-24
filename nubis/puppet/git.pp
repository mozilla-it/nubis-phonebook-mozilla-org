# Ensure that git is installed

package {'git':
    ensure => present,
    name   => 'git'
}
