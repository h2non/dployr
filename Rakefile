require "rspec/core/rake_task"
require "bundler/gem_tasks"

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
  t.rspec_opts = '--color --order defined --format documentation' # --fail-fast
end

task :test => :spec
task :default => :spec
