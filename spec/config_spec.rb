require 'spec_helper'

describe Halley::Config do

  describe :read_yaml do
    it "should expose the read method" do
      Halley::Config.respond_to?(:read_yaml).should be_true
    end

    it "should read the file contents" do
      Halley::Config.read_yaml(File.dirname(__FILE__) + '/fixtures/config.yml').should have(1).item
    end
  end

  describe :discover do
    let(:pwd) { Dir.pwd }
    let(:filename) { Halley::Config::FILENAME }
    let(:fixtures) { File.join File.dirname(__FILE__), 'fixtures' }

    describe "current directory" do
      context "when cannot discover" do
        it { Halley::Config.discover.should be(nil) }
      end

      context "when discover" do
        let(:expected) { File.join fixtures, filename }

        before do
          @base = File.join File.dirname(__FILE__), 'fixtures'
          Dir.chdir @base
        end

        it { Halley::Config.discover.should_not be_empty }

        it { Halley::Config.discover.should eql expected }

        after do
          Dir.chdir pwd
        end
      end
    end

    describe "higher directories" do
      context "when discover" do
        let(:expected) { File.join fixtures, filename }

        before do
          Dir.chdir File.join fixtures, 'config', 'subfolder', 'nested'
        end

        it { Halley::Config.discover.should eql(expected) }

        after do
          Dir.chdir pwd
        end
      end
    end

  end

end
