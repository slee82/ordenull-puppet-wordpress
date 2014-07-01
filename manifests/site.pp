# == Resource: wordpress
#
# This resource will create and maintain a WordPress installation
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
# [*mysql_schema*]
#   The name of the MySQL database to use for this WordPress site.
#
# [*mysql_prefix*]
#   The table prefix in the MySQL database
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
# [*admin_pass*]
#   The WordPress admin password to set during a fresh installation. If
#   left blank, a password will be generated and sent to the admin email.
#
# [*hostname*]
#   The domain name for this installation. This will set the WP_HOME and 
#   WP_SITEURL parameters in wp-puppet.php
#
# [*home*]
#   The home directory for this WordPress installation. Under this directory
#   will be the 'public' directory hosting this WordPress deployment.
#
# [*debug*]
#   Setting this to true will enable WP_DEBUG in wp-puppet.php
#
# [*git_repo*]
#   If left blank, this will be an unversioned WordPress installation. However
#   if you set this to an address of a GIT repository then this becomes a versoned
#   installation. It should be a blank repository without a "master" branch for
#   the fresh installation of WordPress to succeed and check in.
#   If it's an existing repository (with a master branch), then it has  to be
#   in a compatible format with the public directory hosting the WordPress code
#   and the sql database in sql/database.sql
#
# === Examples
#
#  class { 'wordpress':
#    mysql_host  => 'blogs.mysql.mydomain.com',
#    admin_email => 'webmaster@mydomain.com',
#  }
#
#  wordpress::site { 'wordpress':
#    mysql_user   => 'myblog',
#    mysql_pass   => 'secret',
#    mysql_schema => 'wp_myblog',
#    hostname     => 'www.mydomain.com',
#    home         => '/srv/wordpress',
#    git_repo     => 'ssh://git@github.com/username/my-private-repo.git',
#  }
#
#  wordpress::site { 'company':
#    mysql_host   => 'company.mysql.mydomain.com',
#    mysql_user   => 'company',
#    mysql_pass   => 'supersecret',
#    mysql_schema => 'company',
#    owner        => 'copany',
#    group        => 'copany',
#    mode         => '660',
#    hostname     => 'www.mycompany.com',
#    home         => '/srv/company',
#    git_repo     => 'ssh://git@github.com/username/my-company-repo.git',
#  }
#
#  wordpress::site { 'test':
#    mysql_user   => 'test',
#    mysql_pass   => '',
#    mysql_schema => 'test',
#    hostname     => 'localhost',
#    home         => '/srv/test',
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

define wordpress::site (
  $mysql_host       = $wordpress::mysql_host,
  $mysql_user       = $wordpress::mysql_user,
  $mysql_pass       = $wordpress::mysql_pass,
  $mysql_schema     = undef,
  $mysql_prefix     = 'wp_',
  $owner            = $wordpress::owner,
  $group            = $wordpress::group,
  $mode             = $wordpress::mode,
  $admin_email      = $wordpress::admin_email,
  $admin_user       = $wordpress::admin_user,
  $admin_pass       = $wordpress::admin_pass,
  $hostname         = undef,
  $home             = undef,
  $debug            = false,
  $git_repo         = undef,
  $overwrite_config = $wordpress::overwrite_config,
) {
  
  # Make sure that the wordpress class has been defined in this scope
  if !defined( Class['wordpress'] ) {
    fail("you must include the wordpress base class before using any wordpress defined resources")
  }

  # Make sure that any parameters without defaults have been specified
  if $mysql_host == undef {
    fail("wordpress::mysql_host or wordpress::site::mysql_host must be set for Wordpress::Site[$title]")
  }

  if $mysql_user == undef {
    fail("wordpress::mysql_user or wordpress::site::mysql_user must be set for Wordpress::Site[$title]")
  }

  if $mysql_schema == undef {
    fail("wordpress::site::mysql_schema must be set for Wordpress::Site[$title]")
  }

  if $mysql_pass == undef {
    warning("wordpress::mysql_pass or wordpress::site::mysql_pass hasn't been set for Wordpress::Site[$title], will try to connect without a password")
  }

  if $hostname == undef {
    fail("wordpress::site::hostname must be set for Wordpress::Site[$title]")
  }

  if $hostname == undef {
    fail("wordpress::site::home must be set for Wordpress::Site[$title]")
  }

  # Global variables
  $dir_manager = "$home/.puppet"
  $dir_tmp     = "$home/.puppet/tmp"
  $dir_public  = "$home/public"
  $dir_sql     = "$home/sql"

  # Set class defaults
  File {
    owner => $owner,
    group => $group,
    mode  => $mode,
  }

  Exec {
    path => '/bin:/usr/bin',
  }

  # Create the website user and group
  if ! defined( User[$owner] ) {
    user { $owner:
      ensure => present,
      gid    => $group,
    }
  }

  if ! defined( Group[$group] ) {
    group { $group:
      ensure => present,
    }
  }

  # Create the website home directory
  if ! defined( File[$home] ) {
    exec { "wordpress_create_home_$title":
      creates => $home,
      command => "mkdir -p $home",
    }
    file { $home:
      ensure  => directory,
      require => Exec["wordpress_create_home_$title"],
    }
  }

  # Create the supporting directory structure
  if ! defined( File[$dir_public] ) {
    file { $dir_public:
      ensure => directory,
    }
  }

  file { $dir_sql:
    ensure => directory,
  }

  file { $dir_manager:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 0750,
  }

  # Create WordPress management scripts
  file { "$dir_manager/config":
    ensure   => present,
    content  => template('wordpress/config.erb'),
    owner    => root,
    group    => root,
    mode     => 0750,
    require  => File[$dir_manager],
  }

  file { "$dir_manager/tmp":
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => 0750,
  }

  file { "$dir_manager/bin":
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    owner   => root,
    group   => root,
    mode    => 0750,
    source  => "puppet:///modules/wordpress/bin",
  }

  file { "$dir_manager/bin/init-salts":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0750,
    source  => "puppet:///modules/wordpress/bin/init-salts",
  }

  file { "$dir_manager/bin/init-site":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0750,
    source  => "puppet:///modules/wordpress/bin/init-site",
  }

  file { "$dir_manager/bin/init-database":
    ensure  => present,
    mode    => 770,
    owner   => root,
    group   => root,
    content => template('wordpress/init-database.erb'),
  }

  # Main WordPress configuration file
  file { "$dir_public/wp-puppet.php":
    ensure  => present,
    content => template('wordpress/wp-puppet.erb'),
  }

  if ( $overwrite_config == true ) {
    file { "$dir_public/wp-config.php":
      ensure  => present,
      replace => yes,
      content => template('wordpress/wp-config.erb'),
    }
  } else {
    file { "$dir_public/wp-config.php":
      ensure  => present,
      replace => no, # Create once but do not replace
      content => template('wordpress/wp-config.erb'),
    }
  }

  # Generate authentication salts
  exec { "wordpress_generate_salts_$title":
    command => "$dir_manager/bin/init-salts",
    creates => "$dir_public/wp-salts.php",
    require => [ File["$dir_manager/bin/init-salts"], File["$dir_manager/tmp"], File["$dir_public"], File["$dir_manager/config"] ]
  }

  file { "$dir_public/wp-salts.php":
    ensure  => present,
    require => Exec["wordpress_generate_salts_$title"],
  }

  # Install WordPress
  exec { "wordpress_initialize_$title":
    command   => "$dir_manager/bin/init-site",
    creates   => "$dir_public/index.php",
    logoutput => true,
    timeout   => 360,
    require   => [
                   File["$dir_tmp"],
                   File["$dir_manager/config"],
                   File["$dir_manager/bin/init-site"],
                   File["$dir_manager/bin/init-database"],
                   File["$dir_public/wp-config.php"],
                   File["$dir_public/wp-salts.php"],
                   File["$dir_public/wp-puppet.php"]
               ]
  }

}

