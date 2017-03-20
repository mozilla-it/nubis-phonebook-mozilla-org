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

class { 'apache::mod::auth_mellon': }
class { 'apache::mod::php': }

apache::vhost { $project_name:
    servername     => 'https://phonebook-dev.allizom.org',
    serveradmin    => 'webops@mozilla.com',
    port           => 80,
    default_vhost  => true,
    docroot        => '/var/www/html',
    directoryindex => '_revision.txt',
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
  MellonEnable 'auth'
  MellonEndpointPath /mellon
  MellonSPPrivateKeyFile /etc/apache2/mellon/$project_name.key
  MellonSPCertFile /etc/apache2/mellon/$project_name.cert
  MellonSPMetadataFile /etc/apache2/mellon/$project_name.xml
  MellonIdPMetadataFile /etc/apache2/mellon/$project_name.id-metadata.xml
  MellonSecureCookie On

  Require valid-user
  AuthType 'mellon'
</Location>

<Location /mellon>
  AuthType 'none'
  Order allow,deny
  Allow from all
  Satisfy any
</Location>
",
    headers            => [
      "set X-Nubis-Version ${project_version}",
      "set X-Nubis-Project ${project_name}",
      "set X-Nubis-Build   ${packer_build_name}",
      "set X-Content-Type-Options 'nosniff'",
      "set X-Frame-Options 'DENY'",
      "set X-XSS-Protection '1; mode=block'",
      "set Referrer-Policy 'strict-origin-when-cross-origin'"
    ],
    rewrites           => [
      {
        comment      => 'HTTPS redirect',
        rewrite_cond => ['%{HTTP:X-Forwarded-Proto} =http'],
        rewrite_rule => ['. https://%{HTTP:Host}%{REQUEST_URI} [L,R=permanent]'],
      }
    ]
}

