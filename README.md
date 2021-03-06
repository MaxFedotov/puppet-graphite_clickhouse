# puppet-graphite_clickhouse

#### Table of Contents

- [puppet-graphite_clickhouse](#puppet-graphiteclickhouse)
      - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Setup](#setup)
    - [Setup Requirements](#setup-requirements)
    - [Beginning with graphite_clickhouse](#beginning-with-graphiteclickhouse)
  - [Reference](#reference)
  - [Classes](#classes)
    - [graphite_clickhouse](#graphiteclickhouse)
      - [Examples](#examples)
        - [Install graphite-clickhouse.](#install-graphite-clickhouse)
      - [Parameters](#parameters)
        - [`package_name`](#packagename)
        - [`package_ensure`](#packageensure)
        - [`manage_package`](#managepackage)
        - [`package_install_options`](#packageinstalloptions)
        - [`manage_config`](#manageconfig)
        - [`config_dir`](#configdir)
        - [`config_file`](#configfile)
        - [`user`](#user)
        - [`group`](#group)
        - [`override_config`](#overrideconfig)
        - [`datatables_config`](#datatablesconfig)
        - [`service_name`](#servicename)
        - [`service_ensure`](#serviceensure)
        - [`service_enabled`](#serviceenabled)
        - [`manage_service`](#manageservice)
        - [`restart`](#restart)
        - [`enable_logrotate`](#enablelogrotate)
  - [Functions](#functions)
    - [graphite_clickhouse_config](#graphiteclickhouseconfig)
      - [`graphite_clickhouse_config(Hash $Settings)`](#graphiteclickhouseconfighash-settings)
        - [`Settings`](#settings)
    - [graphite_clickhouse_rollup](#graphiteclickhouserollup)
      - [`graphite_clickhouse_rollup(Hash $config)`](#graphiteclickhouserolluphash-config)
  - [Limitations](#limitations)
  - [Development](#development)

## Description

The graphite_clickhouse module installs, configures and manages the graphite-clickhouse service.

## Setup

### Setup Requirements

This module requires toml gem, which is used to translate Hash configuration to graphite-clickhouse toml format configuration files.
To install it you need to execute following command on your puppetmaster server:

```bash
sudo puppetserver gem install toml
```

### Beginning with graphite_clickhouse

To install a graphite_clickhouse with the default options:

`include 'graphite_clickhouse'`

To customize graphite-clickhouse configuration, you must also pass in an override hash:

```puppet
class { 'graphite_clickhouse':
  override_config => {
    'common' => {
      'listen' => ':1010'
    }
  }
}
```

If you want to customize graphite-clickhouse data-tables conguration, use `datatables_config` option:

```puppet
class { 'graphite_clickhouse':
  upload_config => {
    'data-table' => [
      {
        'table'           => 'graphite_reverse',
        'reverse'         => true,
        'rollup-conf'     => "/etc/graphite-clickhouse/rollup.xml",
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
```
This will generate `/etc/graphite-clickhouse/rollup.xml` equal to following carbon configuration files:

`storage-schemas.conf`
```
[default]
pattern=.*
retentions=10:6h,60:15d,600:1y
``` 
`storage-aggregation.conf`
```
[default]
pattern = .*
aggregationMethod = max
```

## Reference
**Classes**

_Public Classes_

* [`graphite_clickhouse`](#graphite_clickhouse): Installs and configures graphite-clickhouse.

_Private Classes_

* `graphite_clickhouse::config`: Private class for graphite-clickhouse configuration.
* `graphite_clickhouse::install`: Private class for managing graphite-clickhouse package.
* `graphite_clickhouse::params`: Private class for setting default graphite-clickhouse parameters.
* `graphite_clickhouse::service`: Private class for managing the graphite-clickhouse service.

**Functions**

* [`graphite_clickhouse_config`](#graphite_clickhouse_config): Convert hash to graphite-clickhouse TOML config.
* [`graphite_clickhouse_rollup`](#graphite_clickhouse_rollup): 

## Classes

### graphite_clickhouse

Installs and configures graphite-clickhouse.

#### Examples

##### Install graphite-clickhouse.

```puppet
class { 'graphite_clickhouse':
  package_name   => 'graphite-clickhouse',
  user           => 'graphite',
  group          => 'graphite',
}
```

#### Parameters

The following parameters are available in the `graphite_clickhouse` class.

##### `package_name`

Data type: `String`

Name of graphite-clickhouse package to install. Defaults to 'graphite-clickhouse'.

Default value: $graphite_clickhouse::params::package_name

##### `package_ensure`

Data type: `String`

Whether the graphite-clickhouse package should be present, absent or specific version.
Valid values are 'present', 'absent' or 'x.y.z'. Defaults to 'present'.

Default value: $graphite_clickhouse::params::package_ensure

##### `manage_package`

Data type: `Boolean`

Whether to manage graphite-clickhouse package. Defaults to 'true'.

Default value: $graphite_clickhouse::params::manage_package

##### `package_install_options`

Data type: `Array[String]`

Array of install options for managed package resources. Appropriate options are passed to package manager.

Default value: $graphite_clickhouse::params::package_install_options

##### `manage_config`

Data type: `Boolean`

Whether the graphite-clickhouse configurations files should be managed. Defaults to 'true'.

Default value: $graphite_clickhouse::params::manage_config

##### `config_dir`

Data type: `Stdlib::Unixpath`

Directory where graphite-clickhouse configuration files will be stored. Defaults to '/etc/graphite-clickhouse'.

Default value: $graphite_clickhouse::params::config_dir

##### `config_file`

Data type: `String`

Name of the file, where graphite-clickhouse configuration will be stored. Defaults to 'graphite-clickhouse.conf'.

Default value: $graphite_clickhouse::params::config_file

##### `user`

Data type: `String`

Owner for graphite-clickhouse configuration and data directories. Defaults to 'graphite-clickhouse'.

Default value: $graphite_clickhouse::params::user

##### `group`

Data type: `String`

Group for graphite-clickhouse configuration and data directories. Defaults to 'graphite-clickhouse'.

Default value: $graphite_clickhouse::params::group

##### `override_config`

Data type: `Optional[Hash[String, Any]]`

Hash[String, Any] of override configuration options to pass to graphite-clickhouse configuration file.

Default value: {}

##### `datatables_config`

Data type: `Hash[String, Array[Hash[String,Any]]]`

Hash[String, Any] of data-tables configuration options to pass to graphite-clickhouse configuration file.

Default value: $graphite_clickhouse::params::datatables_config

##### `service_name`

Data type: `String`

Name of the graphite-clickhouse service. Defaults to 'graphite-clickhouse'.

Default value: $graphite_clickhouse::params::service_name

##### `service_ensure`

Data type: `Stdlib::Ensure::Service`

Specifies whether graphite-clickhouse service should be running. Defaults to 'running'.

Default value: $graphite_clickhouse::params::service_ensure

##### `service_enabled`

Data type: `Boolean`

Specifies whether graphite-clickhouse service should be enabled. Defaults to 'true'.

Default value: $graphite_clickhouse::params::service_enabled

##### `manage_service`

Data type: `Boolean`

Specifies whether graphite-clickhouse service should be managed. Defaults to 'true'.

Default value: $graphite_clickhouse::params::manage_service

##### `restart`

Data type: `Boolean`

Specifies whether graphite-clickhouse service should be restated when configuration changes. Defaults to 'true'.

Default value: $graphite_clickhouse::params::restart

##### `enable_logrotate`

Data type: `Boolean`

Specifies whether logrotate rules should be creatd for graphite-clickhouse logs. Defaults to 'true'.

Default value: $graphite_clickhouse::params::enable_logrotate

## Functions

### graphite_clickhouse_config

Type: Ruby 3.x API

Convert hash to graphite-clickhouse TOML config.

#### `graphite_clickhouse_config(Hash $Settings)`

The graphite_clickhouse_config function.

Returns: `Toml` graphite-clickhouse configuration content.

##### `Settings`

Data type: `Hash`

for graphite-clickhouse.

### graphite_clickhouse_rollup

Type: Ruby 4.x API

The graphite_clickhouse_rollup function.

#### `graphite_clickhouse_rollup(Hash $config)`

The graphite_clickhouse_rollup function.

Returns: `String`

## Limitations

For a list of supported operating systems, see [metadata.json](https://github.com/MaxFedotov/puppet-graphite_clickhouse/blob/master/metadata.json)

## Development

Please feel free to fork, modify, create issues, bug reports and pull requests.