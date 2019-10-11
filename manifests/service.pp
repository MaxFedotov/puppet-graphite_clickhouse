# @summary 
#   Private class for managing the graphite-clickhouse service.
#
# @api private
#
class graphite_clickhouse::service {

  if $graphite_clickhouse::manage_service {
    systemd::unit_file { 'graphite-clickhouse.service':
      content => epp("${module_name}/graphite-clickhouse.service.epp",
      {
        'user'        => $graphite_clickhouse::user,
        'group'       => $graphite_clickhouse::group,
        'config_file' => "${graphite_clickhouse::config_dir}/${graphite_clickhouse::config_file}"
      }),
    }

    if $graphite_clickhouse::manage_package {
      $service_require = [Package[$graphite_clickhouse::package_name], Systemd::Unit_file['graphite-clickhouse.service']]
    } else {
      $service_require = Systemd::Unit_file['graphite-clickhouse.service']
    }

    service { $graphite_clickhouse::service_name:
      ensure  => $graphite_clickhouse::service_ensure,
      enable  => $graphite_clickhouse::service_enabled,
      require => $service_require,
    }

    if $graphite_clickhouse::manage_config {
      File["${graphite_clickhouse::config_dir}/${graphite_clickhouse::config_file}"] -> Service[$graphite_clickhouse::service_name]
    }
  }
}
