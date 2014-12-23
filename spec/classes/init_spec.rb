require 'spec_helper'

class Tests
  PARAMS_CONFIG = {
    :confdir    => '/etc/freight',
    :varlib     => '/var/lib/freight',
    :varcache   => '/var/cache/freight',
    :origin     => 'GenericCompany',
    :label      => 'GenericCompany',
    :gpg        => 'james@fryman.io',
    :gnupghome  => '/etc/freight/keys',
  }

  VALID_PUBRING = 'puppet:///modules/github/freight/pubring.gpg'
  VALID_SECRING = 'puppet:///modules/github/freight/secring.gpg'

  INVALID_PUBRING = 'notarealvalue'
  INVALID_SECRING = 'notarealvalue'

  DEFAULT_FACTS = {
    :operatingsystem => 'Debian',
    :lsbdistcodename => 'lenny',
  }

  DEFAULT_STATE = {
    :ensure => 'present',
    :repo_stage => 'pre',
    :gpgpubring => VALID_PUBRING,
    :gpgsecring => VALID_SECRING,
  }
end

describe 'freight' do
  describe 'failure conditions' do
    context 'gpgpubring is not properly defined' do
      let(:params) { { :gpgpubring => Tests::INVALID_PUBRING } }

      it 'the catalog should fail to compile' do
        expect {
          raise_error(Puppet::Error, "$gpgpubring must be a puppet URI: #{@invalid_pubring}")
        }
      end
    end

    context 'gpgsecring is not properly defined' do
      let(:params) { { :gpgsecring => Tests::INVALID_SECRING } }

      it 'the catalog should fail to compile' do
        expect {
          raise_error(Puppet::Error, "$gpgsecring must be a puppet URI: #{@invalid_secring }")
        }
      end
    end

    context 'neither gpgpubring or gpgsecring is defined' do
      it 'the catalog should fail to compile' do
        expect {
          raise_error(Puppet::Error, 'Must define both $gpgpubring and $gpgsecring')
        }
      end
    end

    context 'gpgpubring is defined and gpgsecring is not defined' do
      let(:params) { { :gpgpubring => Tests::VALID_PUBRING } }
      it 'the catalog should fail to compile' do
        expect {
          raise_error(Puppet::Error, 'Must define both $gpgpubring and $gpgsecring')
        }
      end
    end

    context 'gpgpubring is not defined and gpgsecring is defined' do
      let(:params) { { :gpgsecring => Tests::VALID_SECRING } }
      it 'the catalog should fail to compile' do
        expect {
          raise_error(Puppet::Error, 'Must define both $gpgpubring and $gpgsecring')
        }
      end
    end

    context "gpgpubring is not a valid puppet URI" do
      let(:params) { {
        :gpgpubring => Tests::INVALID_PUBRING,
        :gpgsecring => Tests::VALID_SECRING
      } }

      it 'the catalog should fail to compile' do
        expect {
          raise_error(Puppet::Error, "$gpgpubring must be a Puppet URI: #{Tests::INVALID_PUBRING}")
        }
      end
    end

    context "gpgsecring is not a valid puppet URI" do
      let(:params) { {
        :gpgpubring => Tests::VALID_PUBRING,
        :gpgsecring => Tests::INVALID_SECRING
      } }

      it 'the catalog should fail to compile' do
        expect {
          raise_error(Puppet::Error, "$gpgpubring must be a Puppet URI: #{Tests::INVALID_PUBRING}")
        }
      end
    end
  end

  context 'Installation (ensure => present)' do
    let(:facts) { Tests::DEFAULT_FACTS }
    let(:params) { Tests::DEFAULT_STATE.merge(Tests::PARAMS_CONFIG) }
    it { should contain_class('freight::repo') }
    it { should contain_class('freight::package') }
    it { should contain_class('freight::config') }

    it 'should setup the package key' do
      should contain_anchor__apt__key('rcrowley').with({
        :ensure   => 'present',
        :location => 'http://packages.rcrowley.org/keyring.gpg',
      })
    end

    it 'should setup the apt repository' do
      should contain_anchor__apt__repository('rcrowley').with({
        :ensure   => 'present',
        :location => 'http://packages.rcrowley.org',
        :suites   => 'main',
        :release  => 'lenny',
      })
    end

    it 'should include package resources for installation' do
      should contain_package('freight').with({
        :ensure => 'present',
      })
    end

    it 'should include a file resource to configure freight' do
      should contain_file('/etc/freight.conf').with({
        :ensure  => 'present',
      })
    end

    Tests::PARAMS_CONFIG.each do |k,v|
      it "should include the text #{v} in the config file" do
        should contain_file('/etc/freight.conf').with_content(/#{v}/)
      end
    end

    it 'should transfer a Public Keyring from a Puppet Manifest' do
      should contain_file('/etc/freight/keys/pubring.key').with({
        :ensure => 'present',
        :source => Tests::VALID_PUBRING
      })
    end

    it 'should transfer a Secret Keyring from a Puppet Manifest' do
      should contain_file('/etc/freight/keys/secring.key').with({
        :ensure => 'present',
        :source => Tests::VALID_SECRING
      })
    end

    it 'should create a config dir' do
      should contain_file('/etc/freight').with({
        :ensure => 'directory',
        :force  => nil
      })
    end

    it 'should create a key directory' do
      should contain_file('/etc/freight/keys').with({
        :ensure => 'directory',
        :force  => nil
      })
    end

    it 'should create a varlib directory' do
      should contain_file('/var/lib/freight').with({
        :ensure => 'directory'
      })
    end

    it 'should create a varcache directory' do
      should contain_file('/var/cache/freight').with({
        :ensure => 'directory'
      })
    end
  end

  context 'Uninstallation (ensure => absent)' do
    let(:facts) { Tests::DEFAULT_FACTS }
    let(:params) { { :ensure => 'absent' } }

    it { should contain_class('freight::repo') }
    it { should contain_class('freight::package') }
    it { should contain_class('freight::config') }

    it 'should remove the package key' do
      should contain_anchor__apt__key('rcrowley').with({
        :ensure   => 'absent',
        :location => 'http://packages.rcrowley.org/keyring.gpg',
      })
    end

    it 'should remove the apt repository' do
      should contain_anchor__apt__repository('rcrowley').with({
        :ensure   => 'absent',
        :location => 'http://packages.rcrowley.org',
        :suites   => 'main',
        :release  => 'lenny',
      })
    end

    it 'should include package resources for installation' do
      should contain_package('freight').with({
        :ensure => 'absent',
      })
    end

    it 'should remove the file resource to configure freight' do
      should contain_file('/etc/freight.conf').with({
        :ensure  => 'absent',
      })
    end

    it 'should remove the Public Keyring' do
      should contain_file('/etc/freight/keys/pubring.key').with({
        :ensure => 'absent',
      })
    end

    it 'should remove the Secret Keyring' do
      should contain_file('/etc/freight/keys/secring.key').with({
        :ensure => 'absent',
      })
    end

    it 'should delete the  config dir' do
      should contain_file('/etc/freight').with({
        :ensure => 'absent',
        :force  => true
      })
    end

    it 'should delete the key directory' do
      should contain_file('/etc/freight/keys').with({
        :ensure => 'absent',
        :force  => true
      })
    end

    it 'should not delete the varlib directory' do
      should contain_file('/var/lib/freight').with({
        :ensure => 'directory',
      })
    end

    it 'should not delete the varcache directory' do
      should contain_file('/var/cache/freight').with({
        :ensure => 'directory',
      })
    end
  end
end
