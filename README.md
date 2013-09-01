# ordenull-wordpress

## Overview

This module manages installations of WordPress. Most parameters can be set in the WordPress class,
they will then act as defaults for the individual sites. Anything declared in the site resource
will of course override what's set in the class.

When using this you should set `home` to an empty or non existent directory and set `git_repo` to
a freshly created GIT repository. Do not initialize the repository. It should not have any commits.
This are the steps that this module will take to install WordPress:

 1. Download the bundle from wordpress.org
 2. Generate the database configuration
 3. Generate authentication salts
 4. Trigger a WordPress installation via php-cli
 5. Email the admin password (Only if it's not specified with `admin_pass`)
 6. Check everything into a GIT repository and push it back to origin

## Directory structure

* `public/wp-config.php` : WordPress configuration that includes wp-puppet.php and wp-salts.php. This file will not be overwritten unless *config_overwrite* is set to true.
* `public/wp-puppet.php` : Include with the database configuration
* `public/wp-salts.php` : Include with the generated authentication salts
* `/sql/database.sql` : The latest SQL database dump taken with each table row on a seperate line for GIT friendliness.
* `.puppet/config` : Bash include with configuration that's used for the admin scripts
* `.puppet/bin` : Administration scripts reside here
* `.puppet/tmp` : Used as temporary storage and locks for administration scripts, safe to delete.
* `.gitignore` : Generated during installation to prevent `wp-puppet.php`, `wp-salts.php` and `.puppet` from making it into the GIT repository.

## Examples

Don't set any defaults :

    class { 'wordpress': }

Set a default database server and admin email address :  

    class { 'wordpress':
      mysql_host  => 'blogs.mysql.mydomain.com',
      admin_email => 'webmaster@mydomain.com',
    }

An unmanaged installation of WordPress in /srv/test. The `mysql_host` should be
set in the WordPress class because it isn't specified for this resouce :

    wordpress::site { 'test':
      mysql_user   => 'test',
      mysql_pass   => '',
      mysql_schema => 'test',
      hostname     => 'localhost',
      home         => '/srv/test',
    }

A GIT managed WordPress installation :

    wordpress::site { 'wordpress':
      mysql_user   => 'myblog',
      mysql_pass   => 'secret',
      mysql_schema => 'wp_myblog',
      hostname     => 'www.mydomain.com',
      home         => '/srv/wordpress',
      git_repo     => 'ssh://git@github.com/username/my-private-repo.git',
    }

a GIT managed WordPress installation on a non default MySQL server with more
restrictive file permissions :

    wordpress::site { 'company':
      mysql_host   => 'company.mysql.mydomain.com',
      mysql_user   => 'company',
      mysql_pass   => 'supersecret',
      mysql_schema => 'company',
      owner        => 'copany',
      group        => 'copany',
      mode         => '660',
      hostname     => 'www.mycompany.com',
      home         => '/srv/company',
      git_repo     => 'ssh://git@github.com/username/my-company-repo.git',
    }
