class wordpress::params {

  if $::osfamily == 'Debian' {
    $owner = 'www-data'
    $group = 'www-data'
  } else {
    $owner = 'www-data'
    $group = 'www-data'
    fail("Class['wordpress']: Unsupported osfamily: ${::osfamily}")
  }

}

