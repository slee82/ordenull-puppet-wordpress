class wordpress::params {

  if $::osfamily == 'Debian' {
    $owner = 'www-data'
    $group = 'www-data'
  } else {
    fail("Class['wordpress']: Unsupported osfamily: ${::osfamily}")
  }

}

