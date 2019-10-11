# @summary
#   Private class for setting default graphite-clickhouse parameters.
#
# @api private
#
class graphite_clickhouse::params {
  $package_name             = 'graphite-clickhouse'
  $package_ensure           = 'present'
  $manage_package           = true
  $package_install_options  = []
  $manage_config            = true
  $config_dir               = '/etc/graphite-clickhouse'
  $config_file              = 'graphite-clickhouse.conf'
  $user                     = 'graphite-clickhouse'
  $group                    = 'graphite-clickhouse'
  $service_name             = 'graphite-clickhouse'
  $service_ensure           = 'running'
  $service_enabled          = true
  $manage_service           = true
  $restart                  = true
  $enable_logrotate         = true
  $datatables_config        = {
    'data-table' => [
      {
        'table'           => 'graphite_reverse',
        'reverse'         => true,
        'rollup-conf'     => "${config_dir}/rollup.xml",
        'storage-schemas' => {
          'default' => {
            'pattern'           => '.*',
            'retentions'        => '10:6h,60:15d,600:1y',
            'aggregationMethod' => 'max',
          }
        }
      }
    ]
  }
}
