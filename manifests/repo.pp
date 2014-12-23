# Class: freight::repo
#
# This class manages the setup and configuration of external
# repository necessary to install Freight. It is called from
# the module 'freight'
#
# Parameters:
#
#   $ensure: Manage state of APT Source and Key (present|absent) [String]
#
# Actions:
#
#   This module sets up the APT GPG Key, and installs a sources.list.d entry.
#
# Requires:
#
#   Apt
#
# Sample Usage:
#
# This class file is not called directly
class freight::repo(
  $ensure = present,
) {
  apt::source { 'rcrowley':
    location    => 'http://packages.rcrowley.org',
    repos       => 'main',
    key         => '7DF49CEF',
    key_source  => 'http://packages.rcrowley.org/keyring.gpg',
    include_src => false,
  }
  # Need to fix ordering before OSS
  Exec['apt_update'] -> Package['freight']
}
