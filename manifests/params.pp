# Class: freight::params
#
# This class contains sensible defaults for Class: freight
#
# Parameters:
#
#    $ensure:     Enable/Disable this module (present|absent) [Optional]
#    $confdir:    Directory that contains the base for Freight GPG
#                  Key Management (String) [Optional]
#    $packages    Packages to be installed (per OS) for Freight
#                  (Array) [Optional]
#    $varlib:     Directory for the Freight Library (String) [Optional]
#    $varcache:   Directory for the Freight Cache. Webserver document root
#                  should point here. (String) [Optional]
#    $origin:     Default `Origin` field for `Release` files
#                  (String) [Optional]
#    $label:      Default `Label` field for `Release` files.
#                  (String) [Optional]
#    $gpg:        GPG key used to sign repositories. (String) [Optional]
#    $gnupghome:  Directory where GPG Public/Secret rings are stored
#                  (String) [Recommended]
#    $repo_stage: Run-Stage used to setup/install repository. Must be before
#                   Stage['main'] (String) [Recommended]
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#   include freight::params
#
class freight::params {

  # OS Specific Defaults
  case $::operatingsystem {
    'ubuntu', 'debian': {
      # Environment Defaults
      $confdir = '/etc/freight'

      # Dependencies of Freight are not explicitly managed in order to
      # prevent prevent dependency conflicts from other modules.
      $packages = [ 'freight' ]
      $version  = 'present'
    }
    default: {
      fail("Unrecgonized Operating System: ${::operatingsystem}")
    }
  }

  # Config Defaults
  $varlib    = '/var/lib/freight'
  $varcache  = '/var/cache/freight'
  $origin    = 'Freight'
  $label     = 'Freight'
  $gpg       = 'example@example.com'
  $gnupghome = "${confdir}/keys"

  # Puppet Configuration
  $repo_stage = 'pre'
}
