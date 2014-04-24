require 'optparse'
require 'dployr'
require 'dployr/version'
require 'dployr/cli/commands'

command = ARGV[0]
options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner   = "  Usage: dployr <command> [options]"
  opt.separator  ""
  opt.separator  "  Commands"
  opt.separator  ""
  opt.separator  "    start     start instances"
  opt.separator  "    halt      stop instances"
  opt.separator  "    destroy   destroy instances"
  opt.separator  "    status    retrieve the instances status"
  opt.separator  "    test      run remote test in instances"
  opt.separator  "    deploy    start, provision and test running instances"
  opt.separator  "    provision instance provisioning"
  opt.separator  "    config    generate configuration in YAML from Dployrfile"
  opt.separator  "    execute   run custom stages"
  opt.separator  "    init      create a sample Dployrfile"
  opt.separator  ""
  opt.separator  "  Options"
  opt.separator  ""

  opt.on("-n", "--name NAME", "template name identifier to load") do |v|
    options[:name] = v
  end

  opt.on("-f", "--file PATH", "custom config file path to load") do |v|
    options[:file] = v
  end

  opt.on("-a", "--attributes ATTRS", "aditional attributes to pass to the configuration in matrix query format") do |v|
    options[:attributes] = v
  end

  opt.on("-p", "--provider VALUES", "provider to use (allow multiple values comma-separated)") do |v|
    options[:provider] = v
  end

  opt.on("-r", "--region REGION", "region to use (allow multiple values comma-separated)") do |v|
    options[:region] = v
  end

  opt.on("-v",  "-V", "--version", "version") do
    puts Dployr::VERSION
  end

  opt.on("-h", "--help", "help") do
    puts opt_parser
    exit 0
  end

  opt.separator  ""
end

opt_parser.parse!

case command
when "start"
  Dployr::CLI::Start.new options
when "halt"
  Dployr::CLI::Halt.new options
when "destroy"
  Dployr::CLI::Destroy.new options
when "status"
  puts "Command currently not available"
when "provision"
  Dployr::CLI::Provision.new options
when "test"
  puts "Command currently not available"
when "deploy"
  puts "Command currently not available"
when "execute"
  puts "Command currently not available"
when "config"
  Dployr::CLI::Config.new options
when "init"
  Dployr::Config::Create.write_file
when '-h', '--help', 'help'
  # help already showed by option
else
  puts opt_parser
end
