require 'net/ssh'

module Dployr
  module Scripts
    class Shell

      def initialize(ip, host, username, private_key_path, script)
        @ip = ip
        @host = host
        @username = username
        @private_key_path = private_key_path
        @script = script
        start
      end

      private

      def start
        puts "Connecting to #{@host} (SSH)...".yellow
        Net::SSH.start(@ip, @username, :keys => [@private_key_path]) do |ssh|
          command = @script["remote_path"]
          arguments = @script["args"]
          arguments = arguments.join ' ' if arguments.is_a? Array
          total_command = command
          total_command = command + ' ' + arguments if arguments

          puts "Running remote script '#{command} #{arguments}'".yellow
          result = ssh_exec!(ssh, total_command)
          if result[:exit_code] > 0
            raise "Exit code #{result[:exit_code]} when running script '#{total_command}'".yellow
          else
            puts "Remote script '#{command} #{arguments}' finished succesfully".yellow
          end
        end
      end

      # http://craiccomputing.blogspot.com.es/2010/08/printing-colored-text-in-unix-terminals.html
      def ssh_exec!(ssh, command)
        stdout_data = ""
        stderr_data = ""
        exit_code = nil
        exit_signal = nil
        ssh.open_channel do |channel|
          @channel = channel
          channel.exec(command) do |ch, success|
            unless success
              abort "FAILED: couldn't execute command (ssh.channel.exec)"
            end
            channel.on_data do |ch,data|
              stdout_data+=data
              #print "[#{@host}] #{data}".green
              print "#{data}".green
            end

            channel.on_extended_data do |ch,type,data|
              stderr_data += data
              #print "[#{@host}] #{data}".red
              print "#{data}".red
            end

            channel.on_request("exit-status") do |ch,data|
              exit_code = data.read_long
              @channel.close
            end

          end
        end
        ssh.loop
        {
          stdout_data: stdout_data,
          stderr_data: stderr_data,
          exit_code: exit_code
        }
      end
    end
  end
end
