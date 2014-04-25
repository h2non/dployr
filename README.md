# dployr [![Build Status](https://secure.travis-ci.org/innotech/dployr.svg?branch=master)][travis] [![Dependency Status](https://gemnasium.com/innotech/dployr.svg)][gemnasium] [![Gem](https://badge.fury.io/rb/dployr.svg)][gem]

> Multicloud management and deployment made simple

> **Spoiler! Alpha project. Funny work in progress**

<table>
<tr>
<td><b>Version</b></td><td>alpha</td>
</tr>
<tr>
<td><b>Stage</b></td><td>WIP</td>
</tr>
</table>

## About

**Dployr** is a Ruby utility that simplifies cloud management
and deployment across different providers

You can configure your infraestructure and deployment from a simple configuration file which support built-in
rich features like templating and inheritance

Dployr only works in Ruby >= `1.9.x`

## Installation

```bash
$ gem install dployr
```

Or add it as dependency in your `Gemfile` or `.gemspec` file
```ruby
# gemspec
spec.add_dependency 'dployr', '>= 0.0.1'
# Gemfile
gem 'dployr', '>= 0.0.1'
```

## Documentation

Dployr documentation and API is available from [RubyDoc][rubydoc]

## Features

`To do! but all will be cool :)`

## Configuration

Configuration file must be called `Dployrfile`. It can be also a standard Ruby file
or a YAML file (adding the `.yml` or `.yaml` extension)

#### Data schema

Each configuration level supports the followings members:

- **attributes** `Object` Custom attrbutes to apply to the current template
- **scripts** `Array|Object`
- **providers** `Object`
- **authentication** `Object` (optional)
- **extends** `String|Array` Allows to inherits the current config object from others

#### Templating

Dployr allows templating features inside configuration values, in order
to provide an easy and clean way to dynamically replace values and self-referenced variables
inside the same configuration

Supported template values notations

##### Attributes

Attribute values are available to be referenciable from any part of the config document

Notation: `%{attribute-name}`

##### Iteration context variables

You can reference to the current `provider` or `region` of the current iteration context

Notation: `${region}`

##### Environment variables

Notation: `${HOME}`

#### Example

Featured example configuration file (YAML)
```yaml
---
default:
  attributes:
    name: "default"
    prefix: dev
    private_key_path: ~/pems/private.pem
  authentication:
    private_key_path: ~/.ssh/id_rsa
    public_key_path: ~/.ssh/id_rsa.pub
    username: ubuntu
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
  name: 1
  web-server:
    attributes:
      prefix: zeus-dev
    authentication:
      private_key_path: ~/.ssh/id_rsa
      public_key_path: ~/.ssh/id_rsa.pub
      username: ubuntu
    providers:
      aws:
        regions:
        attributes:
          instance_type: m1.medium
      gce:
        attributes:
          instance_type: m1.large
    scripts:
      post-start:
        -
          args:
            - "%{name}"
            - "%{type}"
            - "%{domain}"
          path: ./scripts/.sh
      -
        args:
          - "%{hydra}"
        path: ./scripts/configureListener.sh
      -
        args:
          - "%{$provider}-%{region}"
          - "%{type}"
        path: ./scripts/hydraProbe.sh

```

## Command-line interface

```
Usage: dployr <command> [options]

Commands

  start     start instances
  halt      stop instances
  destroy   destroy instances
  status    retrieve the instances status
  test      run remote test in instances
  deploy    start, provision and test running instances
  provision instance provisioning
  config    generate configuration in YAML from Dployrfile
  execute   run custom stages
  init      create a sample Dployrfile

Options

  -n, --name NAME                  template name identifier to load
  -f, --file PATH                  custom config file path to load
  -a, --attributes ATTRS           aditional attributes to pass to the configuration in matrix query format
  -p, --provider VALUES            provider to use (allow multiple values comma-separated)
  -r, --region REGION              region to use (allow multiple values comma-separated)
  -v, -V, --version                version
  -h, --help                       help

```

## Programmatic API

```ruby
Dployr::configure do |dployr|

  dployr.config.add_instance({
    attributes: {
      name: "example",
      instance_type: "m1.small",
      version: "${VERSION}"
    },
    scripts: [
      { path: "configure.sh" }
    ],
    providers: {
      aws: {
        attributes: {
          network_id: "be457fca",
          instance_type: "m1.small",
          "type-%{name}" => "small"
        },
        regions: {
          "eu-west-1a" => {
            attributes: {
              keypair: "vagrant-aws-ireland"
            },
            scripts: [
              { path: "router.sh", args: ["%{name}", "${region}", "${provider}"] }
            ]
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

To publish the new version to Rubygems:
```
$ rake release
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
