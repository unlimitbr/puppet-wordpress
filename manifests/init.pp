#init.pp
class wordpress (	$source = 'http://wordpress.org/latest.tar.gz',
			$installdir = '/var/www',
			$dbhost = 'localhost',
			$dbname = 'wordpress',
			$dbuser = 'wordpress',
			$dbpass,
			$dbcharset = 'utf8',
			$vhost = 'localhost',
			$themes = [],
		) {

  if !$dbpass {
    fail("The following variables are mandatory: dbpass")
  }

  # Install package requirements
  $prereqs = [ "php5-mysql", "php5-gd" ]
  define pkgpreq {
    if !defined(Package[$title]) {
      package { $title: ensure => present; }
    }
  }
  pkgpreq {$prereqs: }

  archive { $name:
    ensure => present,
    url    => $source,
    target => "${installdir}",
    checksum => false,
    extension => "tar.gz",
  }

  file { "$installdir/wordpress":
    owner => 'www-data', group => 'root',
    recurse => true, 
  }

  file { "${installdir}/wordpress/wp-config.php":
    owner => 'root', group => 'www-data', mode => '0440',
    content => template('wordpress/wp-config.php.erb'),
    require => Archive[$name],
  }

  class { 'apache':
    mpm_module => false,
    keepalive => 'off',
    keepalive_timeout => '15',
    timeout => '45',
  }

  class { 'apache::mod::prefork': 
    startservers => '1',
    minspareservers => '1',
    maxspareservers => '3',
    serverlimit => '256',
    maxclients => '10',
    maxrequestsperchild => '3000',
  }
  include apache::mod::php

  apache::vhost { $vhost:
    port    => '80',
    docroot => "$installdir/wordpress",
    require => Archive[$name],
  }

  wordpress::theme { $themes: }

} 
