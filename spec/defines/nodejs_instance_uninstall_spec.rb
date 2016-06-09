require 'spec_helper'

describe 'nodejs::instance::uninstall' do
  let(:title) { 'nodejs::instance::uninstall' }

  describe 'any instance' do
    let(:params) {{
      :node_version       => 'v0.12',
      :node_unpack_folder => '/usr/local/node/node-v0.12',
      :node_target_dir    => '/usr/local/bin'
    }}

    it { should contain_file('/usr/local/node/node-v0.12') \
      .with(:ensure => 'absent', :force => true, :recurse => true) \
    }
    it { should contain_file('/usr/local/bin/node-v0.12') \
      .with_ensure('absent') \
    }
  end
end
