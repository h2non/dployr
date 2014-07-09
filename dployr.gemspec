$:.push File.expand_path("../lib", __FILE__)
require 'dployr/version'

Gem::Specification.new do |s|
  s.name        = "dployr"
  s.version     = Dployr::VERSION
  s.summary     = "Multicloud management and deployment made simple"
  s.description = "Multicloud management and deployment made simple from a single configuration file with a featured CLI and programmatic API, supporting deployment stages, local scripts and remote scripts execution and more"
  s.authors     = ["Tomas Aparicio", "German Ramos"]
  s.email       = ["nerds@innotechapp.com"]
  s.homepage    = "https://github.com/innotech/dployr"
  s.license     = "MIT"
  s.rubyforge_project = "dployr"

  s.bindir        = "bin"
  s.require_paths = ["lib"]
  s.executables   = ["dployr"]

  s.rdoc_options     = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md]

  s.add_dependency "fog", "~> 1.21"
  s.add_dependency "deep_merge", "~> 1.0"
  s.add_dependency "net-ssh", "~> 2.9.0"
  s.add_dependency "net-scp", "~> 1.2.0"
  s.add_dependency "colorize", "~> 0.7.2"

  s.add_development_dependency "rake", "~> 10"
  s.add_development_dependency "rspec", "~> 2"

  s.required_ruby_version = ">= 1.9.3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
