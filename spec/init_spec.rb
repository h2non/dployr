require 'spec_helper'

describe Dployr::Init do
  describe "instance configuration" do
    pwd = Dir.pwd
    fixtures = File.join File.dirname(__FILE__), 'fixtures'

    before :all do
      Dir.chdir fixtures
    end

    after :all do
      Dir.chdir pwd
    end

    describe "file discovery" do

      before :all do
        @dployr = Dployr::Init.new
        @dployr.load_config
      end

      it "should discover Dployrfile" do
        @dployr.file_path.should eql "#{fixtures}/Dployrfile"
      end

      it "should create a new config instance" do
        @dployr.config.should be_instance_of Dployr::Configuration
      end
    end

    describe "custom path" do

      before :all do
        @dployr = Dployr::Init.new
        @dployr.load_config File.join File.dirname(__FILE__), 'fixtures', 'Dployrfile.yml'
      end

      it "should load with custom path" do
        @dployr.file_path.should eql "#{fixtures}/Dployrfile.yml"
      end

      it "should create a new config instance" do
        @dployr.config.should be_instance_of Dployr::Configuration
      end
    end
  end
end
