require 'spec_helper'

describe 'nodejs::instance::install', :type => :define do
  let(:title) { 'nodejs::instance::install' }
  let(:facts) {{
    :kernel        => 'linux',
    :hardwaremodel => 'x86',
    :osfamily      => 'Debian',
  }}

  describe 'with specific version v6.0.0' do

    let(:params) {{
      :node_version       => 'v6.0.0',
      :node_unpack_folder => '/usr/local/node/node-v6.0.0',
      :node_target_dir    => '/usr/local/bin',
      :make_install       => true
    }}

    it { should contain_file('nodejs-install-dir') \
      .with_ensure('directory')
    }

    it { should contain_nodejs__instance__install__download('nodejs-download-v6.0.0') \
      .with_source('http://nodejs.org/dist/v6.0.0/node-v6.0.0.tar.gz') \
      .with_destination('/usr/local/node/node-v6.0.0.tar.gz')
    }

    it { should contain_file('nodejs-check-tar-v6.0.0') \
      .with_ensure('file') \
      .with_path('/usr/local/node/node-v6.0.0.tar.gz')
    }

    it { should contain_exec('nodejs-unpack-v6.0.0') \
      .with_command('tar -xzvf node-v6.0.0.tar.gz -C /usr/local/node/node-v6.0.0 --strip-components=1') \
      .with_cwd('/usr/local/node') \
      .with_unless('test -f /usr/local/node/node-v6.0.0/bin/node')
    }

    it { should contain_file('/usr/local/node/node-v6.0.0') \
      .with_ensure('directory')
    }

    it { should contain_exec('nodejs-make-install-v6.0.0') \
      .with_command('./configure --prefix=/usr/local/node/node-v6.0.0 && make && make install') \
      .with_cwd('/usr/local/node/node-v6.0.0') \
      .with_unless('test -f /usr/local/node/node-v6.0.0/bin/node')
    }

    it { should contain_file('nodejs-symlink-bin-with-version-v6.0.0') \
      .with_ensure('link') \
      .with_path('/usr/local/bin/node-v6.0.0') \
      .with_target('/usr/local/node/node-v6.0.0/bin/node')
    }

    it { should contain_file('npm-symlink-bin-with-version-v6.0.0') \
      .with_ensure('file') \
      .with_mode('0755') \
      .with_path('/usr/local/bin/npm-v6.0.0') \
      .with_content(/(.*)\/usr\/local\/bin\/node-v6.0.0 \/usr\/local\/node\/node-v6.0.0\/bin\/npm "\$@"/)
    }

    it { should_not contain_file('/usr/local/bin/node') }
    it { should_not contain_file('/usr/local/bin/npm') }

    it { should_not contain_nodejs__instance__install__download('npm-download-v6.0.0') }
    it { should_not contain_exec('npm-install-v6.0.0') }
  end

  describe 'with make_install = false' do
    let(:params) {{
      :node_version       => 'v6.0.0',
      :node_unpack_folder => '/usr/local/node/node-v6.0.0',
      :node_target_dir    => '/usr/local/bin',
      :make_install       => false
    }}

    it { should_not contain_exec('nodejs-make-install-v6.0.0') }
  end
end
