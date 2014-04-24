require 'logger'
require 'net/scp'
require 'colorize'
require 'dployr/utils'

module Dployr
  module Scripts
    class Scp

      include Dployr::Utils

      def initialize(ip, host, username, private_key_path, script)

        begin
          @log = Logger.new STDOUT
          puts "Connecting to #{host} (SCP)...".yellow
          Net::SCP.start(ip, username, :keys => [private_key_path]) do |scp|
            source = script["source"]
            target = script["target"]
            puts "Coping #{source} -> #{target}".yellow
            scp.upload(source, target, :recursive => true, :preserve => true)
          end

        rescue Exception => e
          @log.error e
          raise Error.new "Cannot copy to remote: #{e}"
        end
      end
    end
  end
end