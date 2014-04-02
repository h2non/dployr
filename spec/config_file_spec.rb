require 'spec_helper'

describe Dployr::Config do

  describe :read_yaml do
    it "should expose the read method" do
      Dployr::Config.respond_to?(:read_yaml).should be_true
    end

    it "should read the file contents" do
      Dployr::Config.read_yaml(File.dirname(__FILE__) + '/fixtures/config.yml').should have(1).item
    end
  end

  describe :discover do

    let(:pwd) { Dir.pwd }
    let(:filename) { Dployr::Config::FILENAME }
    let(:tmpdir) { File.join File.dirname(__FILE__), 'fixtures', '.tmp' }
    let(:fixtures) { File.join File.dirname(__FILE__), 'fixtures' }

    describe "current directory" do
      context "when cannot discover" do
        it { Dployr::Config.discover.should eql nil }
      end

      context "when discover" do
        let(:expected) { File.join fixtures, filename }

        before do
          Dir.chdir fixtures
        end

        it { Dployr::Config.discover.should_not be_empty }

        it { Dployr::Config.discover.should eql expected }

        after do
          Dir.chdir pwd
        end
      end
    end

    describe "higher directories" do
      context "when discover" do
        let(:expected) { File.join fixtures, filename }

        before do
          FileUtils.mkdir_p File.join tmpdir, 'sample'
          Dir.chdir File.join tmpdir, 'sample'
        end

        after do
          Dir.chdir pwd
          FileUtils.rm_rf tmpdir
        end

        it { Dployr::Config.discover.should eql expected }

      end
    end

  end

end
