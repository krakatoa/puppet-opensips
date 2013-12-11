# == Class: opensips
#
# Full description of class opensips here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { opensips:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Fernando Dario Alonso <krakatoa1987@gmail.com>
#
# === Copyright
#
# Copyright 2013 Fernando Dario Alonso
#
class opensips(
  $opensips_autostart = true,
  $opensips_version = "1.10"
) {

  case $opensips_version {
    '1.10': { $opensips_pkg_version = "110" }
    default: { notify "Version not found" }
  }

  include apt

  apt::key { 'opensips':
    key   => '45BF6982',
    key_source => 'http://apt.opensips.org/key.asc'
  }

  apt::source { 'opensips':
    location => "http://apt.opensips.org/",
    release => "stable${opensips_pkg_version}",
    repos => "main",
    include_src => false
  }

  $opensips_packages = [ "opensips" ]

  package { "opensips":
    name => $opensips_packages,
    ensure => 'installed',
    require => Apt::Source['opensips'],
  }

  file { "/etc/default/opensips":
    path => "/etc/default/opensips",
    content => template("opensips/default/opensips"),
    require => Package['opensips'],
    notify => Service['opensips']
  }

  service { 'opensips':
    name => 'opensips',
    ensure => running
  }
}
