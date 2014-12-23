# Class: freight::package
#
# This class manages package installation of Freight, based on
# operating system.  It is called from the module 'freight'
#
# Parameters:
#
#   $ensure: Manage state of Packages (present|absent) [String]
#
# Actions:
#
#    This class installs packages of Freight via Puppet Package Resource
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class freight::package(
  $ensure = $freight::params::version,
) {
  package { $freight::params::packages:
    ensure => $ensure,
  }
}
