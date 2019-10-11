# @summary 
#   Private class for managing graphite-clickhouse package.
#
# @api private
#
class graphite_clickhouse::install {

  if !defined(Group[$graphite_clickhouse::group]) {
    group { $graphite_clickhouse::group:
      ensure => present,
    }
  }

  if !defined(User[$graphite_clickhouse::user]) {
    user { $graphite_clickhouse::user:
      ensure => present,
      groups => $graphite_clickhouse::group,
    }
  }

  if $graphite_clickhouse::manage_package {
    package { $graphite_clickhouse::package_name:
      ensure          => $graphite_clickhouse::package_ensure,
      install_options => $graphite_clickhouse::package_install_options,
    }
  }
}
