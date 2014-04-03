$:.push File.expand_path("../lib", __FILE__)
require 'dployr/version'

Gem::Specification.new do |s|
  s.name        = "dployr"
  s.version     = Dployr::VERSION
  s.summary     = "Multicloud management and deployment with asteroids made simple"
  s.description = "Command-line utility that simplifies multicloud management and deployment with build-in rich features"
  s.authors     = ["Tomas Aparicio"]
  s.homepage    = "https://github.com/innotech/dployr"
  s.license     = "MIT"
  s.rubyforge_project = "dployr"

  s.bindir        = "bin"
  s.require_paths = "lib"
  s.executables   = ["dployr"]

  s.rdoc_options     = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md]

  s.add_dependency "fog", "~> 1.0"
  s.add_dependency "deep_merge", "~> 1.0.1"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
