require 'spec_helper'

describe 'nodejs::instance', :type => :define do
  let(:title) { 'nodejs::instance' }
  let(:facts) {{
    :kernel        => 'linux',
    :hardwaremodel => 'x86',
    :osfamily      => 'Debian',
  }}

  before(:each) {
    Puppet::Parser::Functions.newfunction(:nodejs_stable_version, :type => :rvalue) {
        |args| 'v6.2.0'
    }
    Puppet::Parser::Functions.newfunction(:nodejs_latest_version, :type => :rvalue) {
        |args| 'v6.2.0'
    }
    Puppet::Parser::Functions.newfunction(:validate_nodejs_version) {
        |args| 'v6.2.0'
    }
  }

  describe 'with default parameters' do
    let(:params) {{}}

    it { should contain_nodejs__instance__install('node-setup-install-v6.2.0') \
      .with_node_version('v6.2.0') \
      .with_node_unpack_folder('/usr/local/node/node-v6.2.0') \
      .with_node_target_dir('/usr/local/bin') \
      .with_make_install(true) \
    }
  end

  describe 'with absent=false' do
    let(:params) {{
      :ensure => 'absent'
    }}

    it { should contain_nodejs__instance__uninstall('node-setup-uninstall-v6.2.0') \
      .with_node_version('v6.2.0') \
      .with_node_unpack_folder('/usr/local/node/node-v6.2.0') \
      .with_node_target_dir('/usr/local/bin') \
    }
  end

  describe 'with latest version' do
    let(:params) {{
      :version => 'latest'
    }}

    it { should contain_nodejs__instance__install('node-setup-install-v6.2.0') \
      .with_node_version('v6.2.0') \
      .with_node_unpack_folder('/usr/local/node/node-v6.2.0') \
      .with_node_target_dir('/usr/local/bin') \
      .with_make_install(true) \
    }
  end

  describe 'with specific version' do
    let(:params) {{
      :version => 'v5.4.0'
    }}

    it { should contain_nodejs__instance__install('node-setup-install-v5.4.0') \
      .with_node_version('v5.4.0') \
      .with_node_unpack_folder('/usr/local/node/node-v5.4.0') \
      .with_node_target_dir('/usr/local/bin') \
      .with_make_install(true) \
    }
  end

  describe 'with make_install=false' do
    let(:params) {{
      :make_install => false
    }}

    it { should contain_nodejs__instance__install('node-setup-install-v6.2.0') \
      .with_node_version('v6.2.0') \
      .with_node_unpack_folder('/usr/local/node/node-v6.2.0') \
      .with_node_target_dir('/usr/local/bin') \
      .with_make_install(false) \
    }
  end

  describe 'with a given target dir' do
    let(:params) {{
      :target_dir => '/bin'
    }}

    it { should contain_nodejs__instance__install('node-setup-install-v6.2.0') \
      .with_node_version('v6.2.0') \
      .with_node_unpack_folder('/usr/local/node/node-v6.2.0') \
      .with_node_target_dir('/bin') \
      .with_make_install(true) \
    }
  end
end
