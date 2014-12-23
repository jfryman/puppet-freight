# Class: freight
#
# This module installs and configures Freight, a Debian archiving tool.
#
# Parameters:
#
#    $ensure:     Enable/Disable this module (present|absent) [Optional]
#    $confdir:    Directory that contains the base for Freight GPG
#                  Key Management (String) [Optional]
#    $varlib:     Directory for the Freight Library (String) [Optional]
#    $varcache:   Directory for the Freight Cache. Webserver document root
#                  should point here. (String) [Optional]
#    $origin:     Default `Origin` field for `Release` files.
#                  (String) [Optional]
#    $label:      Default `Label` field for `Release` files. (String) [Optional]
#    $gpg:        GPG key used to sign repositories. (String) [Optional]
#    $gnupghome:  Directory where GPG Public/Secret rings are stored
#                   (String) [Recommended]
#    $repo_stage: Run-Stage used to setup/install repository. Must be before
#                   Stage['main'] (String) [Recommended]
#    $gpgpubring: Puppet URI to GPG Public Ring for Key Management
#                   (String) [Required]
#    $gpgsecring: Puppet URI to GPG Secret Ring for Key Management
#                   (String) [Required]
#
# Actions:
#
#   This module installs Freight, and sets up the basic directory structure
#   for package management.
#
# Requires:
#
#   Apt
#
# Sample Usage:
#
#    class { 'freight':
#      ensure     => present,
#      gpg        => 'james@fryman.io',
#    }
#
# Inclusion of the repository that hosts fright must be explictly called with
#   include freight::repo
class freight(
  $ensure     = 'present',
  $confdir    = $freight::params::confdir,
  $varlib     = $freight::params::varlib,
  $varcache   = $freight::params::varcache,
  $origin     = $freight::params::origin,
  $label      = $freight::params::label,
  $gpg        = $freight::params::gpg,
  $gnupghome  = $freight::params::gnupghome,
  $gpgpubring = undef,
  $gpgsecring = undef,
) inherits freight::params {

  class { 'freight::package':
    ensure     => $freight::params::version,
  }
  -> class { 'freight::config':
    ensure     => $ensure,
    confdir    => $confdir,
    varlib     => $varlib,
    varcache   => $varcache,
    origin     => $origin,
    label      => $label,
    gpg        => $gpg,
    gnupghome  => $gnupghome,
    gpgpubring => $gpgpubring,
    gpgsecring => $gpgsecring,
  } -> Class['freight']

}
