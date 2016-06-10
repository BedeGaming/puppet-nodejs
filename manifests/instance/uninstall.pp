# = Define: nodejs::instance::uninstall
#
# == Parameters:
#
# [*node_version*]
#   The version to remove.
#
# [*node_unpack_folder*]
#   The target directory of nodejs.
#
# [*node_target_dir*]
#   The target dir.
#
define nodejs::instance::uninstall($node_version, $node_unpack_folder, $node_target_dir) {
  include '::nodejs::params'

  validate_string($node_version)
  validate_string($node_unpack_folder)
  validate_string($node_target_dir)

  if $caller_module_name != $module_name {
    warning('::nodejs::instance::uninstall is not meant for public use!')
  }

  if $::nodejs_installed_version == $node_version {
    fail('Default instance must not be removed!')
  }

  file { $node_unpack_folder:
    ensure  => absent,
    force   => true,
    recurse => true,
  } ->
  file { "${node_target_dir}/node-${node_version}":
    ensure => absent,
  }
}
