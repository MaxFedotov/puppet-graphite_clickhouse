# @summary
#   Private class for graphite-clickhouse configuration.
#
# @api private
#
class graphite_clickhouse::config {

  case true {
    $facts['processorcount'] <= 2 : { $max_cpu = $facts['processorcount'] }
    default: { $max_cpu = $facts['processorcount'] - 2 }
  }
# taken from https://github.com/lomik/graphite-clickhouse-tldr/blob/master/graphite-clickhouse.conf
  $default_config = {
    'common'     => {
      'listen'  => ':9090',
      'max-cpu' => $max_cpu,
    },
    'clickhouse' => {
      'url'           => 'http://clickhouse:8123/?max_query_size=2097152&readonly=2',
      'index-table'   => 'graphite_index',
      'data-timeout'  => '1m0s',
      'index-timeout' => '1m0s',
      'tagged-table'  => 'graphite_tagged',
    },
    'logging'    => {
      'file'  => '/var/log/graphite-clickhouse/graphite-clickhouse.log',
      'level' => 'info',
    },
    'carbonlink' => {
      'server'              => '127.0.0.1:7002',
      'threads-per-request' => 10,
      'connect-timeout'     => '50ms',
      'query-timeout'       => '100ms',
      'total-timeout'       => '500ms',
    }
  }
  $real_datatables_config = { 'data-table' => ($graphite_clickhouse::datatables_config.map |$param, $config| { $config.map |$datatable| { delete($datatable, 'storage-schemas') }}).flatten()}
  $config = deep_merge($default_config, $real_datatables_config, $graphite_clickhouse::override_config)
  $log_dir = dirname($config['logging']['file'])

  file { $log_dir:
    ensure => directory,
    owner  => $graphite_clickhouse::user,
    group  => $graphite_clickhouse::group,
    mode   => '2755',
  }

  if $graphite_clickhouse::manage_config {
    file { $graphite_clickhouse::config_dir:
      ensure => directory,
      owner  => $graphite_clickhouse::user,
      group  => $graphite_clickhouse::group,
      mode   => '2755',
    }

    file { "${graphite_clickhouse::config_dir}/${graphite_clickhouse::config_file}":
      content => graphite_clickhouse_config($config),
      owner   => $graphite_clickhouse::user,
      group   => $graphite_clickhouse::group,
      mode    => '0755',
      require => File[$graphite_clickhouse::config_dir],
    }

    $graphite_clickhouse::datatables_config.each |$param, $config| {
      $config.each |$datatable| {
        if ('rollup-conf' in $datatable) and ('storage-schemas' in $datatable) {
          file { "${datatable['rollup-conf']}":
            content => graphite_clickhouse_rollup($datatable['storage-schemas']),
            owner   => $graphite_clickhouse::user,
            group   => $graphite_clickhouse::group,
            mode    => '0755',
            require => File[$graphite_clickhouse::config_dir],
          }
        }
      }
    }
  }

  if $graphite_clickhouse::enable_logrotate {
    logrotate::rule { 'graphite-clickhouse-logrotate':
      path         => [ "${log_dir}/*.log" ],
      missingok    => true,
      copytruncate => true,
      su           => true,
      su_user      => $graphite_clickhouse::user,
      su_group     => $graphite_clickhouse::group,
      rotate       => 5,
      rotate_every => 'daily',
      compress     => false,
      require      => File[$log_dir],
    }
  }
}
