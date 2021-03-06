# = Class: nodejs
#
# == Parameters:
#
# [*version*]
#   The NodeJS version ('vX.Y.Z', 'latest' or 'stable').
#
# [*target_dir*]
#   Where to install the executables.
#
# [*make_install*]
#   If false, will install from nodejs.org binary distributions.
#
# [*node_path*]
#   Value of the system environment variable (default: "/usr/local/node/node-default/lib/node_modules").
#
# [*python_package*]
#   Python package name, defaults to python
#
# [*git_package*]
#   Git package name, defaults to git
#
# == Example:
#
#  include nodejs
#
#  class { 'nodejs':
#    version  => 'v0.10.17'
#  }
#
class nodejs(
  $version        = 'stable',
  $target_dir     = '/usr/local/bin',
  $make_install   = true,
  $node_path      = '/usr/local/node/node-default/lib/node_modules',
  $python_package = 'python',
  $git_package    = 'git',
) {
  validate_string($node_path)

  $node_version = $version ? {
    undef    => nodejs_stable_version(),
    'stable' => nodejs_stable_version(),
    'latest' => nodejs_latest_version(),
    default  => $version
  }

  nodejs::install { "nodejs-${version}":
    version        => $node_version,
    target_dir     => $target_dir,
    make_install   => $make_install,
    python_package => $python_package,
    git_package    => $git_package,
  }

  $nodejs_version_path = "/usr/local/node/node-${$node_version}"
  $nodejs_default_path = '/usr/local/node/node-default'

  file { $nodejs_default_path:
    ensure  => link,
    target  => $nodejs_version_path,
    require => Nodejs::Install["nodejs-${version}"],
  }

  $node_default_symlink = "${target_dir}/node"
  $node_default_symlink_target = "${nodejs_default_path}/bin/node"
  $npm_default_symlink = "${target_dir}/npm"
  $npm_default_symlink_target = "${nodejs_default_path}/bin/npm"
  
  file { $node_default_symlink:
    ensure  => link,
    target  => $node_default_symlink_target,
    require => File[$nodejs_default_path]
  }
  
  file { $npm_default_symlink:
    ensure  => link,
    target  => $npm_default_symlink_target,
    require => File[$nodejs_default_path]
  }

  file { '/etc/profile.d/nodejs.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/nodejs.sh.erb"),
    require => File[$nodejs_default_path],
  }
}
