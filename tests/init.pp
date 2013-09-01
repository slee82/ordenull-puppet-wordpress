  class { 'wordpress':
    mysql_host  => 'blogs.mysql.mydomain.com',
    admin_email => 'webmaster@mydomain.com',
  }

  wordpress::site { 'wordpress':
    mysql_user   => 'myblog',
    mysql_pass   => 'secret',
    mysql_schema => 'wp_myblog',
    hostname     => 'www.mydomain.com',
    home         => '/srv/wordpress',
    git_repo     => 'ssh://git@github.com/username/my-private-repo.git',
  }

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

  wordpress::site { 'test':
    mysql_user   => 'test',
    mysql_pass   => '',
    mysql_schema => 'test',
    hostname     => 'localhost',
    home         => '/srv/test',
  }
