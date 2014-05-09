# dployr [![Build Status](https://secure.travis-ci.org/innotech/dployr.svg?branch=master)][travis] [![Dependency Status](https://gemnasium.com/innotech/dployr.svg)][gemnasium] [![Gem](https://badge.fury.io/rb/dployr.svg)][gem]

> Multicloud management and deployment made simple

> **Alpha project, use it by your own risk**

<table>
<tr>
<td><b>Version</b></td><td>alpha</td>
</tr>
<tr>
<td><b>Stage</b></td><td>WIP</td>
</tr>
</table>

## About

**Dployr** is a Ruby utility that **simplifies cloud management
and deployment** across different providers

You can setup all your project cloud infraestructure from a
simple configuration file and deploy it into multiple clouds easily

Aditionally, it provides full control and low-level cloud configuration
to define multiple deployment stages which covers full infraestructure workflow,
such as instances creation, network configuration, provisioning, testing and halting

It provides a featured [command-line interface](#command-line-interface) and [programmatic API](#programmatic-api)

## Installation

```bash
$ gem install dployr
```

If you need to use it from another Ruby package,
add it as dependency in your `Gemfile` or `.gemspec` file
```ruby
# gemspec
spec.add_dependency 'dployr', '~> 0.0.1'
# Gemfile
gem 'dployr', '>= 0.0.1'
```

It requires Ruby `1.9.3+`

## Features

- Fully configurable from Ruby or YAML file with built-in rich features like templating
- Simplifies deployment to multiple cloud providers
- Allows to create the same infraestructe into multiple cloud providers from one command
- Supports default instances and inherited configuration values
- Full control of virtual instances (start, restart, stop, test, provision)
- Allows to run local and remote scripts execution per stage with pre and post hooks
- Featured command-line and programmatic API

## Supported providers

Dployr is still a alpha project, so there are only a few providers supported

- Amazon Web Services (`aws`)
- Google Compute Engine (`gce`)
- Baremetal

Upcoming supported providers by priority

- OpenStack
- Verizon
- Azure
- Rackspace
- XenServer

## Configuration

Configuration file must be called `Dployrfile`. It can be also a standard Ruby file
or a YAML file (adding the `.yml` or `.yaml` extension)

#### Data schema

Each configuration level supports the followings members:

- **attributes** `Object` Custom attributes to apply to the current template
- **scripts** `Object` Scripts hooks per phase to run (start, stop, test...)
- **providers** `Object` Nested configuration provider-specific (aws, gce...)
- **extends** `String|Array` Allows to inherits from other template

#### Templating

Dployr allows templating powerful features inside configuration values, in order
to provide an easy, non-redundant and clean way to dynamically replace values for different usage contexts,
such as specific context cloud provider, deployment region or environment variables

Configuration templates can inherits from others templates,
so you can reuse environments for multiple projects or environments

Supported template values notations

##### Attributes

Attribute values are available to be referenciable from any part of the config document

Notation: `%{attribute-name}`

##### Iteration context variables

You can use references from config strings to specific iteration context values

Notation: `${value}`

Supported values:

- **provider** - Current context provider name identifier
- **region** - Current context region name identifier
- **name** - Current context template name identifier

##### Environment variables

Notation: `${HOME}`

#### Example

Featured example configuration file in YAML
```yml
---
# general configuration applied to templates
default:
  attributes:
    name: "default"
    prefix: dev
    private_key_path: ~/pems/private.pem
  providers:
    aws:
      attributes:
        instance_type: m1.small
      regions:
        eu-west-1a:
          attributes:
            ami: ami-f5ca3682
            keypair: vagrant-aws-ireland
            security_groups:
              - sg-576c7635
              - sg-1e648a7b
            subnet_id: subnet-be457fca
        us-west-2b:
          attributes:
            ami: ami-c66608f6
            keypair: vagrant-aws-oregon
            security_groups:
              - sg-88283cea
              - sg-f233ca97
            subnet_id: subnet-ef757e8d
    gce:
      attributes:
        client_email: sample@mail.com
        instance_type: m1.small
        key_location: ~/pems/privatekey.p12
        project_id: innotechapp
      regions:
        europe-west1-a:
          attributes:
            ami: centos-base-v5
            instance_type: n1-standard-1
            network: liberty-gce
  scripts:
    pre-start:
      -
        path: ./scripts/routes_allregions.sh
    start:
      -
        args: "%{name}"
        path: ./scripts/updatedns.sh

custom:
  attributes:
    prefix: zeus-dev
  providers:
    aws:
      regions:
      attributes:
        instance_type: m1.medium
        public_ip: new # create a elastic IP
    gce:
      attributes:
        instance_type: m1.large
  scripts:
    pre-start:
      - args:
          - "%{name}"
          - "%{type}"
          - "%{domain}"
        path: ./scripts/pre-start.sh
    start:
      - args:
          - "%{hydra}"
        path: ./scripts/configure.sh
    provision:
      - args:
          - "%{$provider}-%{region}"
          - "%{type}"
        path: ./scripts/provision.sh
    test:
      - path: ./scripts/serverspec.sh
```

## Command-line interface

```
Usage: dployr <command> [options]

Commands

  start     start instances
  halt      stop instances
  destroy   destroy instances
  status    retrieve the instances status
  info      retrieve instance information and output it in YAML format
  test      run remote test in instances
  deploy    start, provision and test running instances
  provision instance provisioning
  config    generate configuration in YAML from Dployrfile
  execute   run custom stages
  ssh       ssh into machine
  init      create a sample Dployrfile

Options

  -n, --name NAME                  template name identifier to load
  -f, --file PATH                  custom config file path to load
  -a, --attributes ATTRS           aditional attributes to pass to the configuration in matrix query format
  -p, --provider VALUES            provider to use (allow multiple values comma-separated)
  -r, --region REGION              region to use (allow multiple values comma-separated)
  -i, --public-ip                  use public ip instead of private ip to when access instances
      --debug                      enable debug mode
  -v, -V, --version                version
  -h, --help                       help
```

### Examples

Start a new instance. If it don't exists, it will be created
```bash
$ dployr start -n name -p aws -r eu-west-1 -a 'env=dev'
```

Provision an existent working instance
```bash
$ dployr provision -n name -p aws -r eu-west-1 -a 'env=dev'
```

Test a working instance
```bash
$ dployr test -n name -p aws -r eu-west-1 -a 'env=dev'
```

Generate config in YAML format
```bash
$ dployr config -n name -p aws -r eu-west-1 -a 'env=dev'
```

## Programmatic API

You can use the Ruby programmatic API to integrate it in your own implementation

### API

Dployr API documentation is available from [RubyDoc][rubydoc]

### Configuration

Example Dployrfile in Ruby which uses the API to configure your project
```ruby
Dployr::configure do |dployr|

  dployr.config.add_instance(:zeus, {
    attributes: {
      instance_type: "m1.small",
      version: "${VERSION}",
      env: 'dev'
    },
    scripts: [
      { path: "configure.sh" }
    ],
    providers: {
      aws: {
        attributes: {
          ami: 'ami-370daf2a', # centos-base-v7
          keypair: 'vagrant-aws-saopaulo',
          security_groups: ['sg-3cf3e45e'],
          subnet_id: 'subnet-1eebe07c'
          public_ip: 'new'
        },
        regions: {
          "eu-west-1a" => {
            attributes: {
              instance_type: "m1.medium",
              keypair: "vagrant-aws-ireland"
            },
            scripts: {
              start: [
                { path: "router.sh", args: ["${name}", "${region}", "${provider}"] }
              ]
              provision: [
                { path: "puppet.sh", args: ["${name}", "${region}", "${provider}", '--env %{env}'] }
              ]
              post-provision: [
                { path: "clean.sh" }
              ]
            }
          }
        }
      }
    }
  })

end
```

## Contributing

Feel free to report any issue you experiment via Github issues.
PR are also too much appreciated

Only PR which follows the [Ruby coding style][ruby-guide] guide will be accepted.
Aditionally, you must cover with test any new feature or refactor you do

We try to follow the [best RSpec][rspec-best] conventions in our tests

### Development

Only Ruby and Ruby gems are required for development.
To run the development rake tasks, you also need to have `bundler` installed.

Clone/fork this repository
```
$ git clone git@github.com:innotech/dployr.git && cd dployr
```

Install dependencies
```
$ bundle install
```

Before you push any changes, run test specs
```
$ rake test
```

To build a new version of the gem:
```
$ rake build
````

Publish the new version to Rubygems:
```
$ gem push pkg/dployr-0.1.0.gem
```

## Contributors

- [Tomas Aparicio](https://github.com/h2non)
- [Germán Ramos](https://github.com/germanramos)

## License

[MIT](http://opensource.org/licenses/MIT) © Innotech and contributors

[travis]: http://travis-ci.org/innotech/dployr
[gemnasium]: https://gemnasium.com/innotech/dployr
[gem]: http://rubygems.org/gems/dployr
[ruby-guide]: https://github.com/bbatsov/ruby-style-guide
[rspec-best]: http://betterspecs.org/
[rubydoc]: http://www.rubydoc.info/gems/dployr/
