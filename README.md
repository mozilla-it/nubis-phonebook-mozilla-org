# Phonebook Nubis deployment repository

This is the deployment repository for
[phonebook.mozilla.org](https://phonebook.mozilla.org)

## Components

Defined in [nubis/terraform/main.tf](nubis/terraform)

### Webservers

Defined in [nubis/puppet/apache.pp](nubis/puppet)

The produced image is that of a simple Ubuntu Apache webserver running PHP

### Load Balancer

Simple ELB

### SSO

This entire application is protected behind [mod_auth_openidc](https://github.com/zmartzone/mod_auth_openidc)

### Cache

Elasticache/Memcache is used to provide persistency for the application's cache
and for mod_auth_openidc's session cache

## Configuration

The application's configuration file is
[LocalSettings.php](nubis/puppet/files/config-local.php)
and is not managed, it simply sources nubis_configuration
from */etc/nubis-config/${project_name}.php*

### Consul Keys

This application's Consul keys, living under
*${project_name}-${environment}/${environment}/config/*
and defined in Defined in [nubis/terraform/consul.tf](nubis/terraform)

#### ENVIRONMENT

The current deployment's environment

#### ldap-cert

*Operator Supplied* X509, PEM endoded client SSL cert

#### ldap-key

*Operator Supplied* X509, PEM endoded client SSL key

#### ldap_host

*Operator Supplied* LDAP Url to connect to the server, for example

```
ldaps://ldap.company.com:636
```

#### ldap_bind_dn

*Operator Supplied* Bind DN to use to authenticate to the LDAP server

#### ldap_bind_pw

*Operator Supplied* Password to use to authenticate to the LDAP server

#### Cache/Endpoint

DNS endpoint of Elasticache/memcache

#### Cache/Port

TCP port of Elasticache/memcache

The hostname of the RDS/MySQL Database

#### OpenID/Server/Memcached

Hostname:Port of Elasticache/memcache

#### OpenID/Server/Passphrase

*Generated* OpenID passphrase for session encryption

#### OpenID/Client/Domain

*Operator Supplied* Auth0 Domain for this application, typically 'mozilla'

#### OpenID/Client/ID

*Operator Supplied* Auth0 Client ID for this application

#### OpenID/Client/Secret

*Operator Supplied* Auth0 Client Secret for this application 'mozilla'

#### OpenID/Client/Site

*Operator Supplied* Auth0 Site URL for this application

## Cron Jobs

None

## Logs

No application specific logs
