# @summary
#   Installs and configures graphite-clickhouse.
#
# @example Install graphite-clickhouse.
#   class { 'graphite_clickhouse':
#     package_name   => 'graphite-clickhouse',
#     user           => 'graphite',
#     group          => 'graphite',
#   }
#
# @param package_name
#   Name of graphite-clickhouse package to install. Defaults to 'graphite-clickhouse'.
# @param package_ensure
#   Whether the graphite-clickhouse package should be present, absent or specific version. 
#   Valid values are 'present', 'absent' or 'x.y.z'. Defaults to 'present'.
# @param manage_package
#   Whether to manage graphite-clickhouse package. Defaults to 'true'.
# @param package_install_options
#   Array of install options for managed package resources. Appropriate options are passed to package manager.
# @param manage_config
#   Whether the graphite-clickhouse configurations files should be managed. Defaults to 'true'.
# @param config_dir
#   Directory where graphite-clickhouse configuration files will be stored. Defaults to '/etc/graphite-clickhouse'.
# @param config_file
#   Name of the file, where graphite-clickhouse configuration will be stored. Defaults to 'graphite-clickhouse.conf'.
# @param user
#   Owner for graphite-clickhouse configuration and data directories. Defaults to 'graphite-clickhouse'.
# @param group
#   Group for graphite-clickhouse configuration and data directories. Defaults to 'graphite-clickhouse'.
# @param override_config
#   Hash[String, Any] of override configuration options to pass to graphite-clickhouse configuration file.
# @param datatables_config
#   Hash[String, Any] of data-tables configuration options to pass to graphite-clickhouse configuration file. 
# @param service_name
#   Name of the graphite-clickhouse service. Defaults to 'graphite-clickhouse'.
# @param service_ensure
#   Specifies whether graphite-clickhouse service should be running. Defaults to 'running'.
# @param service_enabled
#   Specifies whether graphite-clickhouse service should be enabled. Defaults to 'true'.
# @param manage_service
#   Specifies whether graphite-clickhouse service should be managed. Defaults to 'true'.
# @param restart
#   Specifies whether graphite-clickhouse service should be restated when configuration changes. Defaults to 'true'.
# @param enable_logrotate
#   Specifies whether logrotate rules should be creatd for graphite-clickhouse logs. Defaults to 'true'.
#
class graphite_clickhouse (
  String $package_name                                     = $graphite_clickhouse::params::package_name,
  String $package_ensure                                   = $graphite_clickhouse::params::package_ensure,
  Boolean $manage_package                                  = $graphite_clickhouse::params::manage_package,
  Array[String] $package_install_options                   = $graphite_clickhouse::params::package_install_options,
  Boolean $manage_config                                   = $graphite_clickhouse::params::manage_config,
  Stdlib::Unixpath $config_dir                             = $graphite_clickhouse::params::config_dir,
  String $config_file                                      = $graphite_clickhouse::params::config_file,
  String $user                                             = $graphite_clickhouse::params::user,
  String $group                                            = $graphite_clickhouse::params::group,
  Optional[Hash[String, Any]] $override_config             = {},
  Hash[String, Array[Hash[String,Any]]] $datatables_config = $graphite_clickhouse::params::datatables_config,
  String $service_name                                     = $graphite_clickhouse::params::service_name,
  Stdlib::Ensure::Service $service_ensure                  = $graphite_clickhouse::params::service_ensure,
  Boolean $service_enabled                                 = $graphite_clickhouse::params::service_enabled,
  Boolean $manage_service                                  = $graphite_clickhouse::params::manage_service,
  Boolean $restart                                         = $graphite_clickhouse::params::restart,
  Boolean $enable_logrotate                                = $graphite_clickhouse::params::enable_logrotate,
) inherits graphite_clickhouse::params {

  if $restart {
    Class['graphite_clickhouse::config']
    ~> Class['graphite_clickhouse::service']
  }

  anchor { 'graphite_clickhouse::start': }
  -> class { 'graphite_clickhouse::install': }
  -> class { 'graphite_clickhouse::config': }
  -> class { 'graphite_clickhouse::service': }
  -> anchor { 'graphite_clickhouse::end': }
}
