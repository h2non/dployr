# dployr  [![Gem](https://badge.fury.io/rb/dployr.png)][gem]

<!--
[![Build Status](https://secure.travis-ci.org/innotech/dployr.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/innotech/dployr.png)][gemnasium]
-->

[travis]: http://travis-ci.org/innotech/dployr
[gemnasium]: https://gemnasium.com/innotech/dployr
[gem]: http://rubygems.org/gems/dployr

> Multicloud management and deployment with asteroids made simple

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
$ gem install dployr --source https://6wNxkeCE8z3GnoU1TH7f@repo.fury.io/innotech/
```

Or add it as dependency in your `Gemfile` or `.gemspec` file
```ruby
# gemspec
spec.add_dependency 'dployr', '>= 0.0.1'
# Gemfile
source 'https://6wNxkeCE8z3GnoU1TH7f@gem.fury.io/innotech/'
gem 'dployr', '>= 0.0.1'
```

## Usage

### Command-line interface

```
Usage: dployr <command> [options]

Commands

  up        start instances
  halt      stop instances
  status    retrieve the instances status
  test      run remote test in instances
  deploy    start, provision and test running instances
  provision instance provisioning
  config    generate configuration in YAML format
  init      create a sample Dployrfile

Options

  -e, --environment ENV            environment to pass to the instances
  -n, --name NAME                  template name identifier to load
  -a, --attributes ATTRS           aditional attributes to pass to the configuration in matrix query format
  -p, --provider                   provider to use (allow multiple values comma-separated)
  -r, --region                     region to use (allow multiple values comma-separated)
  -h, --help                       help

```

### Programmatic API

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

## Features

`To do! but all will be cool :)`

## Configuration file

Configuration file must be called `Dployrfile`. It can be also a standard Ruby file
or a YAML file (adding the `.yml` or `.yaml` extension)

#### Data schema

Each configuration level supports the followings members:

- **attributes** `Object`
- **scripts** `Array`
- **providers** `Object`
- **authentication** `Object`
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
    name: "%{name}"
    prefix: dev
    private_key_path: ~/pems/innotechdev.pem
    username: innotechdev
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
        client_email: 388158271394-hiqo47ehuagjshtrtsgicsnn0uvmdk06@developer.gserviceaccount.com
        instance_type: m1.small
        key_location: ~/pems/70ddae97bf1c09d2d799b2acde33a03ebd52d774-privatekey.p12
        project_id: innotechapp
      regions:
        europe-west1-a:
          attributes:
            ami: centos-base-v5
            instance_type: n1-standard-1
            network: liberty-gce
  scripts:
    -
      path: ./vagrant-deploy-common/scripts/routes_allregions.sh
    -
      args: "%{name}"
      path: ./vagrant-deploy-common/scripts/updatedns.sh


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
      -
        args:
          - "%{name}"
          - "%{type}"
          - "%{domain}"
        path: ./scripts/configure.sh
      -
        args:
          - "%{hydra}"
        path: ./scripts/configureListener.sh
      -
        args:
          - "%{$provider}-%{region}"
          - "%{type}"
        path: ./vagrant-deploy-common/scripts/hydraProbe.sh

```

## Contributing

Feel free to report any issue you experiment via Github issues.
PR are also too much appreciated

### Development

Only Ruby and Ruby gems are required for development.
To run the development rake tasks, you also need to have `bundler` installed.

Clone/fork this repository
```
$ git clone git@github.com:innotech/dployr.git && cd dployr
```

Install required dependencies
```
$ bundle install
```

Before you push any changes, run the RSpec suite
```
$ rake spec
```

To build a new version of the gem:
```
$ rake build
````

To publish the new version to Rubygems:
```
$ rake release
```

## License

Released under the MIT license
