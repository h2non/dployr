require 'spec_helper'
require 'dployr/commands/config'

describe Dployr::Commands::Config do

  dployrfile = "spec/fixtures/basic/Dployrfile.yml"
  arguments = "config -f #{dployrfile} -n dployr -p aws -r sa-east-1a -a 'index=100'"

  before :all do
    @result = `bin/dployr #{arguments}`
    @exit_code = $?.exitstatus
    puts @result
  end

  it "should have a valid exit code" do
    @result.should be_a String
    @exit_code.should be 0
  end

  describe "attributes" do

    it "should have a valid attribute name" do
      @result.should include "name: dployr"
    end

    it "should have a valid attribute prefix" do
      @result.should include "prefix: dev"
    end

    it "should have a valid attribute private_key_path" do
      @result.should include "private_key_path: ~/pems/innotechdev.pem"
    end

    it "should have a valid attribute username" do
      @result.should include "username: innotechdev"
    end

    it "should have a valid attribute instance_type" do
      @result.should include "instance_type: t1.micro"
    end

    it "should have a valid attribute ami" do
      @result.should include "ami: ami-370daf2a"
    end

    it "should have a valid attribute username" do
      @result.should include "username: innotechdev"
    end

    it "should have a valid attribute keypair" do
      @result.should include "keypair: vagrant-aws-saopaulo"
    end

    it "should have a valid attribute security_groups" do
      @result.should include "security_groups:\n  - sg-3cf3e45e"
    end

    it "should have a valid attribute subnet_id" do
      @result.should include "subnet_id: subnet-1eebe07c"
    end

    it "should has first attribute in script for scp in pre-provision stage" do
      @result.should include ":scripts:\n"\
                             "  pre-provision:\n"\
                             "  - source: ./hello\n"\
                             "    target: /tmp"
    end

    it "should has second attribute in script for remote execute in provision stage" do
      @result.should include "  provision:\n"\
                             "  - remote_path: /tmp/hello/jetty.sh\n"\
                             "    args: ''"
    end

  end

end
