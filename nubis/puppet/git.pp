# Ensure that git is installed

case $::osfamily {
  'RedHat': {
    $git_package_version            = '2.7.3-1.46.amzn1'
  }
  'Debian', 'Ubuntu': {
    $git_package_version            = '1:1.9.1-1ubuntu0.3'
  }
  default: {
    fail("Unknown git version for OS ${::osfamily}")
  }
}

package {
  'git':
    ensure => $git_package_version,
    name   =>  'git'
}
