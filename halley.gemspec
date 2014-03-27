$:.push File.expand_path("../lib", __FILE__)
require 'halley/version'

Gem::Specification.new do |s|
  s.name        = "halley"
  s.version     = Halley::VERSION
  s.summary     = "Multicloud management with asteroids made simple"
  s.description = "Ruby utility that simplifies the multicloud management and provides rich features"
  s.authors     = ["Tomas Aparicio"]
  s.homepage    = "http://github.com/innotech/halley"
  s.license     = "MIT"
  s.rubyforge_project = "halley"

  s.bindir        = "bin"
  s.require_paths = "lib"
  s.executables   = ["halley"]

  s.rdoc_options     = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md]

  s.add_dependency "fog", "~> 1.0"
  s.add_dependency "commander", "~> 4.1"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
