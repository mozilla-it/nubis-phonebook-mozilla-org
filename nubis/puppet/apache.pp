# Define how Apache should be installed and configured

class { 'nubis_apache':
    # update-site provides instructions on where to get Phonebook
    update_script_source   => 'puppet:///nubis/files/update-site.sh',
    update_script_interval => {
        minute => [ fqdn_rand(30), ( fqdn_rand(30) + 30 ) % 60],
    },

    # Changing the Apache mpm is necessary for the Apache PHP module
    mpm_module_type => 'prefork',
}

class { 'apache::mod::php': }

class { 'apache::mod::auth_mellon':
  require => [
    Package['liblasso3'],
  ],
}

class { 'apt': }
apt::ppa { 'ppa:houzefa-abba/lasso': }
package { 'liblasso3':
  ensure => '2.5.1-1~eob80+1+~ubuntu14.04~xcg.ppa1',
  require => [
    Apt::Ppa['ppa:houzefa-abba/lasso'],
  ],
}

apache::vhost { "$project_name":
    serveradmin    => 'webops@mozilla.com',
    port           => 80,
    default_vhost  => false,
    docroot        => '/var/www/html',
    directoryindex => 'index.php',
    docroot_owner  => 'root',
    docroot_group  => 'root',
    block          => ['scm'],
    setenvif       => [
      'X_FORWARDED_PROTO https HTTPS=on',
      'Remote_Addr 127\.0\.0\.1 internal',
      'Remote_Addr ^10\. internal',
    ],
    access_log_env_var => '!internal',
    access_log_format  => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    custom_fragment    => "
Include /etc/apache2/conf-available/servername.conf
# Clustered without coordination
FileETag None

<Directory '/var/www/html'>
  AddType image/svg+xml .svg
  Options None
  AllowOverride None
  Order allow,deny
  Allow from all
  Options ExecCGI SymLinksIfOwnerMatch
</Directory>

<Location />
  MellonEndpointPath /mellon
  MellonSPPrivateKeyFile /etc/apache2/mellon/$project_name.key
  MellonSPCertFile /etc/apache2/mellon/$project_name.cert
  MellonSPMetadataFile /etc/apache2/mellon/$project_name.xml
  MellonIdPMetadataFile /etc/apache2/mellon/$project_name.idp-metadata.xml
  MellonSecureCookie On
  MellonSubjectConfirmationDataAddressCheck Off
</Location>

<Location /mellon>
  AuthType 'none'
  Order allow,deny
  Allow from all
  Satisfy any
</Location>

<Location />
  MellonEnable 'auth'
  AuthType Mellon
  require valid-user
</Location>
",
    headers            => [
      "set X-Nubis-Version ${project_version}",
      "set X-Nubis-Project ${project_name}",
      "set X-Nubis-Build   ${packer_build_name}",
      "set X-Content-Type-Options 'nosniff'",
      "set X-Frame-Options 'DENY'",
      "set X-XSS-Protection '1; mode=block'",
      "set Referrer-Policy 'strict-origin-when-cross-origin'",
      "set Strict-Transport-Security 'max-age=31536000'",
      "set Referrer-Policy 'no-referrer, strict-origin-when-cross-origin'",
      "set Content-Security-Policy \"default-src 'none'; frame-ancestors 'none'; connect-src 'self'; font-src 'self'; img-src 'self'; script-src 'self'; style-src 'self'\"",
      'always set Public-Key-Pins "max-age=1296000; pin-sha256=\"zSvnhQdjmYpQNahZ5voq6EGaNgaT0ElRiy+mzBD7p+k=\"; pin-sha256=\"5kJvNEMw0KjrCAu7eXY5HZdvyCS13BbA0VJG1RSP91w=\"; pin-sha256=\"YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=\"; pin-sha256=\"sRHdihwgkaib1P1gxX8HFszlD+7/gTfNvuAybgLPNis=\""'
    ],
    rewrites           => [
      {
        comment      => 'HTTPS redirect',
        rewrite_cond => ['%{HTTP:X-Forwarded-Proto} =http'],
        rewrite_rule => ['. https://%{HTTP:Host}%{REQUEST_URI} [L,R=permanent]'],
      },
      {
        comment => 'Replaces all requests to / with /index.php internally only - addresses github.com/UNINETT/mod_auth_mellon/issues/38',
        rewrite_rule => ['"^/?$" "/index.php" [PT,QSA]'],
      }
    ]
}

apache::vhost { "svc-healthcheck":
    serveradmin    => 'webops@mozilla.com',
    port           => 443,
    default_vhost  => false,
    docroot        => '/var/www/healthcheck',
    directoryindex => 'index.html',
    docroot_owner  => 'root',
    docroot_group  => 'root'
}
