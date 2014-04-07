# dployr [![Build Status](https://secure.travis-ci.org/innotech/dployr.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/innotech/dployr.png)][gemnasium] [![Gem](https://badge.fury.io/js/dployr.png)][gem]

[travis]: http://travis-ci.org/innotech/dployr
[gemnasium]: https://gemnasium.com/innotech/dployr
[gem]: http://rubygems.org/gems/dployr

> Multicloud management and deployment with asteroids made simple

> **Spoiler! Funny work in progress**

<table>
<tr>
<td><b>Version</b></td><td>beta</td>
</tr>
<tr>
<td><b>Stage</b></td><td>WIP</td>
</tr>
</table>

## About

A Ruby utility that simplifies cloud management across different providers

`to do`

## Installation

```
$ gem install dployr
```

Or add it as dependency in your `Gemfile` or `.gemspec` file
```ruby
# gemspec
spec.add_dependency 'dployr', '>= 0.1.0'
# Gemfile
gem 'dployr', '>= 0.1.0'
```

## Features

`Under design!`

## Configuration file

```yaml

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
