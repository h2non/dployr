require 'logger'
require 'dployr'
require 'dployr/utils'
require 'json'
require 'net/ssh'

module Dployr
  module Provision
    class Shell

      include Dployr::Utils

      def initialize(instance)
      
        begin
          @log = Logger.new STDOUT
          host = instance[:attributes]["name"]
          username = instance[:attributes]["username"]
          private_key_path = instance[:attributes]["private_key_path"]
          
          puts "Making ssh to #{instance[:attributes]["username"]}"
          Net::SSH.start(host, username, :keys => [private_key_path]) do |ssh|
            puts instance.inspect
            instance[:scripts]["provision"].each do |script|
              command = script["path"]
              arguments = script["args"]
              puts "Running remote script '#{command} #{arguments}'"
              result = ssh_exec!(ssh, command)
              puts result.inspect
              if result[:exit_code] > 0
                raise "Exit code #{result[:exit_code]} when running script '#{command} #{arguments}'"
              end
            end
          end
          
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end

      def ssh_exec!(ssh, command)
        stdout_data = ""
        stderr_data = ""
        exit_code = nil
        exit_signal = nil
        ssh.open_channel do |channel|
          channel.exec(command) do |ch, success|
            unless success
              abort "FAILED: couldn't execute command (ssh.channel.exec)"
            end
            channel.on_data do |ch,data|
              stdout_data+=data
              puts data
            end
      
            channel.on_extended_data do |ch,type,data|
              stderr_data+=data
              puts data
            end
      
            channel.on_request("exit-status") do |ch,data|
              exit_code = data.read_long
            end
      
            channel.on_request("exit-signal") do |ch, data|
              exit_signal = data.read_long
            end
          end
        end
        ssh.loop
        {
          stdout_data: stdout_data,
          stderr_data: stderr_data, 
          exit_code: exit_code,
          exit_signal: exit_signal
        }
      end
    end
  end
end