require 'spec_helper'
require 'dployr/commands/config'

describe Dployr::Commands::Config do

  fixture_dployrfile = "spec/fixtures/Dployrfile.cli.test.yml"
  options = "config -f #{fixture_dployrfile} -n german-template -p aws -r sa-east-1a"
   
  before :all do
    @result = `bin/dployr #{options}`
    @exit_code = $?.exitstatus
  end

  describe "Show options config given template, provider and region" do
    
    it "should has option name with value german-template" do
      @result.should include ":name: german-template"
    end
    
    it "should has option file with value spec/fixtures/Dployrfile.cli.test.yml" do
      @result.should include ":file: spec/fixtures/Dployrfile.cli.test.yml"
    end
    
    it "should has option provider with value aws" do
      @result.should include ":provider: aws"
    end
    
    it "should has option region with value sa-east-1a" do
      @result.should include ":region: sa-east-1a"
    end
    
  end

  describe "Show custom config given template, provider and region" do
    
    it "should return 0" do
      @result.should be_a String
      @exit_code.should be 0
    end    
    
    it "should has attribute name with value german-dployr" do
      @result.should include "name: german-dployr"
    end
    
    it "should has attribute prefix with value dev" do
      @result.should include "prefix: dev"
    end
    
    it "should has attribute private_key_path: with value ~/pems/innotechdev.pem" do
      @result.should include "private_key_path: ~/pems/innotechdev.pem"
    end
    
    it "should has attribute username with value innotechdev" do
      @result.should include "username: innotechdev"
    end
    
    it "should has attribute instance_type: with value t1.micro" do
      @result.should include "instance_type: t1.micro"
    end
    
    it "should has attribute ami: with value ami-370daf2a" do
      @result.should include "ami: ami-370daf2a"
    end
    
    it "should has attribute username with value innotechdev" do
      @result.should include "username: innotechdev"
    end
    
    it "should has attribute keypair with value vagrant-aws-saopaulo" do
      @result.should include "keypair: vagrant-aws-saopaulo"
    end

    it "should has attribute security_groups with value sg-3cf3e45e" do
      @result.should include "security_groups:\n  - sg-3cf3e45e"
    end
    
    it "should has attribute subnet_id with value subnet-1eebe07c" do
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

 