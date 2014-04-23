require 'logger'
require 'net/scp'
require 'colorize'
require 'dployr/utils'

module Dployr
  module Provision
    class Scp

      include Dployr::Utils

      def initialize(host, username, private_key_path, script)

        begin
          @log = Logger.new STDOUT
          puts "Connecting to #{host} (SCP)...".yellow
          Net::SCP.start(host, username, :keys => [private_key_path]) do |scp|
            source = script["source"]
            target = script["target"]
            puts "Coping #{source} -> #{target}".yellow
            scp.upload(source, target, :recursive => true, :preserve => true)
          end

        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end
    end
  end
end
