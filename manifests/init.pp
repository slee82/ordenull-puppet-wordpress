# == Class: wordpress
#
# This class sets the defaults for all WordPress installations in this context
#
# === Parameters
#
# [*mysql_host*]
#   The address of the MySQL server
#
# [*mysql_user*]
#   The username for the MySQL server. This user must have access to
#   the MySQL database being used for WordPress.
#
# [*mysql_pass*]
#   The password for the MySQL user
#
# [*owner*]
#   The system user that will own the WordPress files
#
# [*group*]
#   The system user that will own the WordPress files
#
# [*mode*]
#   Default file mode for the WordPress files
#
# [*admin_email*]
#   The email address of the admin user. This user will receive the
#   email with the admin password after a fresh installation. Don't
#   forget to check the spam box.
#
# [*admin_user*]
#   The WordPress admin username to create during a fresh installation.
#
# [*admin_pass*]
#   The WordPress admin password to set during a fresh installation. If
#   left blank, a password will be generated and sent to the admin email.
#
# [*overwrite_config*]
#   Force overwrite the wp-config.php. Normally wp-config.php is only created
#   once and isn't maintained, because some plugins will write settings there.
#   Setting this option to true will cause this file to be overwritten with
#   functional defaults.
#
# === Examples
#
#  class { wordpress: }
#
#  class { 'wordpress':
#    mysql_host  => 'mysql.mydomain.com',
#    mysql_user  => 'wordpress',
#    mysql_pass  => 'secret',
#    admin_email => 'webmaster@mydomain.com',
#  }
#
# === Authors
#
# Author Name <stan@borbat.com>
# Author Blog <http://stan.borbat.com>
#
# === Copyright
#
# Copyright 2013 Stan Borbat, unless otherwise noted.
#
class wordpress (
  $mysql_host       = undef,
  $mysql_user       = undef,
  $mysql_pass       = undef,
  $owner            = $wordpress::params::owner,
  $group            = $wordpress::params::group,
  $mode             = 0660,
  $admin_email      = undef,
  $admin_user       = 'admin',
  $admin_pass       = '',
  $overwrite_config = false,
) inherits wordpress::params {

  if ! defined ( Package['mysql-client'] ) {
    package { 'mysql-client':
      ensure => present
    }
  }

  if ! defined ( Package['php5'] ) {
    package { 'php5':
      ensure => present
    }
  }

  if ! defined ( Package['php5-mysql'] ) {
    package { 'php5-mysql':
      ensure => present
    }
  }

  if ! defined ( Package['php5-cli'] ) {
    package { 'php5-cli':
      ensure => present
    }
  }

  # Necessary to be able to send out the email with the admin password
  if ! defined ( Package['mailutils'] ) {
    package { 'mailutils':
      ensure => present
    }
  }

}

