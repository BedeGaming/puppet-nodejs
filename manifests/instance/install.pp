# = Define: nodejs::instance::install
#
# == Parameters:
#
# [*node_version*]
#   The explicit version of the nodejs to install.
#
# [*node_unpack_folder*]
#   The target dir of the nodejs instances.
#
# [*node_target_dir*]
#   The target dir for the symlinks.
#
# [*make_install*]
#   Condition whether to compile or not.
#
define nodejs::instance::install($node_version, $node_unpack_folder, $node_target_dir, $make_install) {
  include '::nodejs::params'

  validate_string($node_version)
  validate_string($node_unpack_folder)
  validate_string($node_target_dir)
  validate_bool($make_install)

  if $caller_module_name != $module_name {
    warning('::nodejs::instance::install is not meant for public use!')
  }

  $node_os = $::kernel ? {
    /(?i)(darwin)/ => 'darwin',
    /(?i)(linux)/  => 'linux',
    default        => 'linux',
  }

  $node_arch = $::hardwaremodel ? {
    /.*64.*/ => 'x64',
    default  => 'x86',
  }

  $node_filename = $make_install ? {
    true    => "node-${node_version}.tar.gz",
    default => "node-${node_version}-${node_os}-${node_arch}.tar.gz"
  }

  $node_symlink_target = "${node_unpack_folder}/bin/node"
  $node_symlink        = "${node_target_dir}/node-${node_version}"
  $npm_instance        = "${node_unpack_folder}/bin/npm"
  $npm_symlink         = "${node_target_dir}/npm-${node_version}"

  ensure_resource('file', 'nodejs-install-dir', {
    ensure => 'directory',
    path   => $::nodejs::params::install_dir,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  })

  ::nodejs::instance::install::download { "nodejs-download-${node_version}":
    source      => "http://nodejs.org/dist/${node_version}/${node_filename}",
    destination => "${::nodejs::params::install_dir}/${node_filename}",
    require     => File['nodejs-install-dir'],
  }

  file { "nodejs-check-tar-${node_version}":
    ensure  => 'file',
    path    => "${::nodejs::params::install_dir}/${node_filename}",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => ::Nodejs::Instance::Install::Download["nodejs-download-${node_version}"],
  }

  file { $node_unpack_folder:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['nodejs-install-dir'],
  }

  exec { "nodejs-unpack-${node_version}":
    command => "tar -xzvf ${node_filename} -C ${node_unpack_folder} --strip-components=1",
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    cwd     => $::nodejs::params::install_dir,
    user    => 'root',
    unless  => "test -f ${node_symlink_target}",
    require => [
      File["nodejs-check-tar-${node_version}"],
      File[$node_unpack_folder],
      Package['tar'],
    ],
  }

  if $make_install {
    include ::gcc
    ensure_packages([ 'make' ])

    exec { "nodejs-make-install-${node_version}":
      command => "./configure --prefix=${node_unpack_folder} && make && make install",
      path    => "${node_unpack_folder}:/usr/bin:/bin:/usr/sbin:/sbin",
      cwd     => $node_unpack_folder,
      user    => 'root',
      unless  => "test -f ${node_symlink_target}",
      timeout => 0,
      require => [
        Exec["nodejs-unpack-${node_version}"],
        Package['make'],
        Class['::gcc'],
      ],
      before  => File["nodejs-symlink-bin-with-version-${node_version}"],
    }
  }

  file { "nodejs-symlink-bin-with-version-${node_version}":
    ensure => 'link',
    path   => $node_symlink,
    target => $node_symlink_target,
  }

  file { "npm-symlink-bin-with-version-${node_version}":
    ensure  => file,
    mode    => '0755',
    path    => $npm_symlink,
    content => template("${module_name}/npm.sh.erb"),
    require => [File["nodejs-symlink-bin-with-version-${node_version}"]],
  }
}
