class catalog_diff::viewer (
  $remote   = 'https://github.com/camptocamp/puppet-catalog-diff-viewer.git',
  $password = 'puppet',
  $revision = 'master',
  $port     = 1495,
) {
  require git

  class {'apache':
    default_vhost     => false,
    default_ssl_vhost => false,
  }

  apache::vhost {"${::ipaddress}:${port}":
    servername         => $fqdn,
    ip                 => $::ipaddress,
    docroot            => '/var/www/diff',
    ip_based           => true,
    directories        => [
      { path           => '/var/www/diff',
        auth_type      => 'basic',
        auth_name      => 'Catalog Diff',
        auth_user_file => '/var/www/.htpasswd',
        auth_require   => 'valid-user',
      },
    ],
    priority   => '15',
    require    => Htpasswd['puppet'],
    port       => $port,
    add_listen => true,
  }

  htpasswd { 'puppet':
    username    => 'puppet',
    cryptpasswd => ht_sha1($password),
    target      => '/var/www/.htpasswd',
  }

  vcsrepo { '/var/www/diff':
    ensure   => latest,
    provider => 'git',
    source   => $remote,
    revision => $revision,
  }
}
