# Class: freight::config
#
# This class configures Freight, a Debian archiving tool. It is called from
# the module 'freight'
#
# Parameters:
#
#    $ensure:     Enable/Disable this module (present|absent) [Optional]
#    $confdir:    Directory that contains the base for Freight GPG
#                  Key Management (String) [Optional]
#    $varlib:     Directory for the Freight Library (String) [Optional]
#    $varcache:   Directory for the Freight Cache. Webserver document root
#                  should point here. (String) [Optional]
#    $origin:     Default `Origin` field for `Release` files
#                  (String) [Optional]
#    $label:      Default `Label` field for `Release` files. (String) [Optional]
#    $gpg:        GPG key used to sign repositories. (String) [Optional]
#    $gnupghome:  Directory where GPG Public/Secret rings are stored
#                  (String) [Recommended]
#    $gpgpubring: Puppet URI to GPG Public Ring for Key Management
#                  (String) [Required]
#    $gpgsecring: Puppet URI to GPG Secret Ring for Key Management
#                  (String) [Required]
#
# Actions:
#
#   This module configures Freight, and sets up the basic directory structure
#   for package management.
#
# Requires:
#
#  This class has no external dependencies.
#
# Sample Usage:
#
#   This class file is not called directly
class freight::config(
  $ensure     = undef,
  $cache      = 'on',
  $confdir    = undef,
  $varlib     = undef,
  $varcache   = undef,
  $origin     = undef,
  $label      = undef,
  $gpg        = undef,
  $gnupghome  = undef,
  $gpgpubring = undef,
  $gpgsecring = undef
) {
  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  # Case statement to correctly set the attributes of
  # the file resources to correctly toggle between
  # install/purge actions.
  #
  # Set to out of statement for clearer parsing.
  case $ensure {
    'absent': {
      $file_attr_defaults = {
        ensure => 'absent',
      }
      $directory_attr_defaults = {
        ensure => 'absent',
        force  => true,
      }
    }
    default: {
      $file_attr_defaults = {
        ensure => 'present',
      }
      $directory_attr_defaults = {
        ensure => 'directory',
        force  => undef
      }
    }
  }

  # Main Configuration File for Freight
  file { '/etc/freight.conf':
    ensure  => $file_attr_defaults['ensure'],
    content => template('freight/freight.conf.erb'),
  }

  # In the event of $ensure == 'absent', don't automatically
  # delete the directory in the event the user wants to clean
  # their own package repos.
  file { [$varlib, $varcache]:
    ensure  => directory,
  }

  file { [$confdir, $gnupghome]:
    ensure => $directory_attr_defaults['ensure'],
    force  => $directory_attr_defaults['force'],
  }
  File[$gnupghome] {
    mode => '0400',
  }

  # Sync Public/Private Keyrings for Key-Signing
  file { "${gnupghome}/pubring.gpg":
    ensure => $file_attr_defaults['ensure'],
    source => $gpgpubring,
  }
  file { "${gnupghome}/secring.gpg":
    ensure => $file_attr_defaults['ensure'],
    source => $gpgsecring,
  }
}
