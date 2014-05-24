#theme.pp

define wordpress::theme (	$source = $name,
			) {
  if !$source {
    fail("Source variable required!")
  }
  if ! defined(Class["wordpress"]) {
    fail("Class wordpress must be defined first!.")
  }

  if ! defined(Package['unzip']) {
    package { 'unzip': ensure => 'present' }
  }

  $archname = inline_template("<%= name.rpartition('/')[2] %>")

  archive { $archname:
    ensure => present,
    url    => $source,
    target => "${wordpress::installdir}/wordpress/wp-content/themes",
    checksum => false,
    extension => inline_template("<%= source.rpartition('.')[2] %>"),
    require => Package['unzip'],
  }

}
