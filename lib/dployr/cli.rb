require 'optparse'
require 'dployr'
require 'dployr/version'

command = ARGV[0]
options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner   = "\n  Usage: dployr <command> [options]"
  opt.separator  ""
  opt.separator  "  Commands"
  opt.separator  ""
  opt.separator  "    start     start instances or create networks"
  opt.separator  "    halt      stop instances"
  opt.separator  "    destroy   destroy instances or delete networks"
  opt.separator  "    status    retrieve the instances status"
  opt.separator  "    info      retrieve instance information and output it in YAML format"
  opt.separator  "    test      run remote test in instances"
  opt.separator  "    deploy    start, provision and test running instances"
  opt.separator  "    provision instance provisioning"
  opt.separator  "    config    generate configuration in YAML from Dployrfile"
  opt.separator  "    execute   run custom stages"
  opt.separator  "    ssh       ssh into machine (only Unix-like OS)"
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

  opt.on("-i", "--public-ip", "use public ip instead of private ip to when access to instances") do |v|
    options[:public_ip] = v
  end

  opt.on("--debug", "enable debug mode") do
    options[:debug] = true
  end

  opt.on("-v",  "-V", "--version", "version") do
    puts Dployr::VERSION
    exit 0
  end

  opt.on("-h", "--help", "help") do
    puts opt_parser
    exit 0
  end

  opt.separator  ""
end

opt_parser.parse!

def run(command, options, arg = nil)
  begin
    cmd = Dployr::Commands.const_get command
    raise "Command not supported: #{command}" unless cmd
    if arg
      cmd.new options, arg
    else
      cmd.new options
    end
  rescue => e
    puts "Error: #{e}".red
    puts e.backtrace if e.backtrace and options[:debug]
    exit 1
  end
end

case command
when "start"
  run :Start, options
when "halt"
  run :StopDestroy, options, "halt"
when "destroy"
  run :StopDestroy, options, "destroy"
when "status"
  puts "Command currently not available"
when "info"
  run :Info, options
when "provision"
  run :ProvisionTest, options, "provision"
when "test"
  run :ProvisionTest, options, "test"
when "deploy"
  run :Start, options
  run :ProvisionTest, options, "provision"
  run :ProvisionTest, options, "test"
when "execute"
  run :Execute, options, ARGV[1..-1]
when "ssh"
  run :Ssh, options
when "config"
  run :Config, options
when "init"
  Dployr::Config::Create.write_file
else
  puts opt_parser
end
