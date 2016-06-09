# = Define: nodejs::install
#
# == Parameters:
#
# [*ensure*]
#   Whether to install or uninstall an instance.
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
# == Example:
#
#  class { 'nodejs':
#    version => 'v0.10.17',
#  }
#
#  nodejs::install { 'v0.10.17':
#    version => 'v0.10.17'
#  }
#
define nodejs::instance (
  $ensure       = present,
  $version      = undef,
  $target_dir   = undef,
  $make_install = true,
) {
  validate_bool($make_install)
  if $caller_module_name != $module_name {
    warning('::nodejs::instance is not meant for public use!')
  }

  include nodejs::params

  $stable       = nodejs_stable_version()
  $node_version = $version ? {
    undef    => $stable,
    'stable' => $stable,
    'latest' => nodejs_latest_version(),
    default  => $version
  }

  validate_nodejs_version($node_version)

  $node_target_dir = $target_dir ? {
    undef   => $::nodejs::params::target_dir,
    default => $target_dir
  }

  $node_unpack_folder = "${::nodejs::params::install_dir}/node-${node_version}"

  if $ensure == present {
    ::nodejs::instance::install { "node-setup-install-${node_version}":
      node_version       => $node_version,
      node_unpack_folder => $node_unpack_folder,
      node_target_dir    => $node_target_dir,
      make_install       => $make_install,
    }
  } else {
    ::nodejs::instance::uninstall { "node-setup-uninstall-${node_version}":
      node_version       => $node_version,
      node_unpack_folder => $node_unpack_folder,
      node_target_dir    => $node_target_dir,
    }
  }
}
