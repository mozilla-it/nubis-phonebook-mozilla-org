# Define how Apache should be installed and configured

class { 'nubis_apache':
    # update-site provides instructions on where to get Phonebook
    # update_script_source   => 'puppet:///nubis/files/update-site.sh',
    # update_script_interval => {
    #     minute => [ fqdn_rand(30), ( fqdn_rand(30) + 30 ) % 60],
    # },

    # Changing the Apache mpm is necessary for the Apache PHP module
    mpm_module_type => 'prefork',
    check_url       => '/_health_'
}

class { 'apache::mod::php': }

file { "/var/www/${project_name}/_health_":
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => "HEALTHY\n",
}

apache::vhost { $project_name:
    serveradmin        => 'webops@mozilla.com',
    port               => 80,
    default_vhost      => false,
    docroot            => "/var/www/${project_name}",
    directoryindex     => 'index.php',
    docroot_owner      => 'root',
    docroot_group      => 'root',
    block              => ['scm'],
    setenvif           => [
      'X_FORWARDED_PROTO https HTTPS=on',
      'Remote_Addr 127\.0\.0\.1 internal',
      'Remote_Addr ^10\. internal',
    ],
    access_log_env_var => '!internal',
    access_log_format  => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    custom_fragment    => "
        # Don't set default expiry on anything
        ExpiresActive Off

        # Clustered without coordination
        FileETag None

        ${::nubis::apache::sso::custom_fragment}
    ",
    directories        => [
      {
        'path'      => "/var/www/${project_name}",
        'provider'  => 'directory',
        'auth_type' => 'openid-connect',
        'require'   => 'valid-user',
      },
      {
        'path'      => '/_health_',
        'provider'  => 'location',
        'auth_type' => 'None',
        'require'   => 'all granted',
      },
    ],
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
    ],
    rewrites           => [
      {
        comment      => 'HTTPS redirect',
        rewrite_cond => ['%{HTTP:X-Forwarded-Proto} =http'],
        rewrite_rule => ['. https://%{HTTP:Host}%{REQUEST_URI} [L,R=permanent]'],
      },
    ]
}
