require 'spec_helper'

describe Dployr::Init do
  describe "instance configuration" do
    pwd = Dir.pwd
    fixtures = File.join File.dirname(__FILE__), 'fixtures'

    before :all do
      Dir.chdir fixtures
      @dployr = Dployr::Init.new
    end

    after :all do
      Dir.chdir pwd
    end

    describe "file discovery" do
      it "should discover the file" do
        @dployr.file_path.should eql "#{fixtures}/Dployrfile"
      end

      it "should create a new config instance" do
        @dployr.config.should be_instance_of Dployr::Configuration
      end
    end
  end
end
