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
    serveradmin    => 'webops@mozilla.com',
    port           => 80,
    default_vhost  => true,
    docroot        => '/var/www/html',
    directoryindex => '_revision.txt',
    docroot_owner  => 'root',
    docroot_group  => 'root',
    directories    => [
      {
        path                       => '/',
        provider                   => 'location',
        mellon_enable              => 'auth',
        mellon_sp_private_key_file => '/etc/apache2/mellon/$project_name.key',
        mellon_sp_cert_file        => '/etc/apache2/mellon/$project_name.cert',
        mellon_sp_metadata_file    => '/etc/apache2/mellon/$project_name.xml',
        mellon_idp_metadata_file   => '/etc/apache2/mellon/$project_name.id-metadata.xml',
        mellon_endpoint_path       => '/mellon',
        auth_require               => 'valid-user'
      },
      {
        path          => '/mellon',
        provider      => 'location',
        mellon_enable => 'info',
        auth_type     => 'None'
      }
    ]
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
",
    headers            => [
      "set X-Nubis-Version ${project_version}",
      "set X-Nubis-Project ${project_name}",
      "set X-Nubis-Build   ${packer_build_name}",
    ],
    rewrites           => [
      {
        comment      => 'HTTPS redirect',
        rewrite_cond => ['%{HTTP:X-Forwarded-Proto} =http'],
        rewrite_rule => ['. https://%{HTTP:Host}%{REQUEST_URI} [L,R=permanent]'],
      }
    ]
}

