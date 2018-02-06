<?php

require_once "/etc/nubis-config/phonebook.php";

/*
 * This is where you would override certain config values, locally.
 * Copy this to config-local.php and change the values as appropriate.
 * If this file does not exist, they default to the values shown here.
 */

// LDAP
define('LDAP_HOST', $ldap_host);
define('LDAP_BIND_DN', $ldap_bind_dn);
define('LDAP_BIND_PW', $ldap_bind_pw);

// only non-human and/or admin accounts match this filter -- 20160411 atoll
define('LDAP_EXCLUDE', '(!(mail=*_*@mozilla.com))');

if (empty($Cache_Endpoint)) {
  define("MEMCACHE_ENABLED", false);
}
else {
  // Memcache (port number is mandatory)
  define("MEMCACHE_ENABLED", true);
  define('MEMCACHE_PREFIX', 'phonebook');
  $memcache_servers = array(
    "$Cache_Endpoint:$Cache_Port",
  );
}

// Restrict the number of results returned for user-initiated searches (0 == no limit)
define('RESULT_SIZE_LIMIT', 24);

// Should we include SRI hashes on all <script> and <link rel="stylesheet"> tags?
define("ENABLE_SRIHASH", true);
// Developers --
//   'make sri' must be run to regenerate the list of hashes in 'config-srihashes.php'
//   for all JS/CSS files listed in 'srihash_files.txt'.
