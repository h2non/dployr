require 'spec_helper'
require 'dployr/commands/utils'

describe Dployr::Commands::Utils do

  describe :parse_matrix do
    describe "replacement using hash" do
      data = "name=dployr ; lang = ruby"

      before do
        @result = Dployr::Commands::Utils.parse_matrix data
      end

      it "should return a valid type" do
        @result.should be_a Hash
      end

      it "should have a valid number of items" do
        @result.should have(2).items
      end

      it "should exists the name key" do
        @result.should have_key 'name'
      end

      it "should have a valid value" do
        @result['name'].should eql 'dployr'
      end

      it "should exists the lang key" do
        @result.should have_key 'lang'
      end

      it "should have a valid value" do
        @result['lang'].should eql 'ruby'
      end
    end
  end

  describe :parse_flags do
    describe "replacement using hash" do
      data = "--name dployr --lang ruby "

      before do
        @result = Dployr::Commands::Utils.parse_flags data
      end

      it "should return a valid type" do
        @result.should be_a Hash
      end

      it "should have a valid number of items" do
        @result.should have(2).items
      end

      it "should exists the name key" do
        @result.should have_key 'name'
      end

      it "should have a valid value" do
        @result['name'].should eql 'dployr'
      end

      it "should exists the lang key" do
        @result.should have_key 'lang'
      end

      it "should have a valid value" do
        @result['lang'].should eql 'ruby'
      end
    end
  end

  describe :parse_attributes do
    describe "parse matrix values attributes" do
      data = "name=dployr ; lang = ruby"

      before do
        @result = Dployr::Commands::Utils.parse_attributes data
      end

      it "should return a valid type" do
        @result.should be_a Hash
      end

      it "should have a valid number of items" do
        @result.should have(2).items
      end

      it "should exists the name key" do
        @result.should have_key 'name'
      end

      it "should have a valid value" do
        @result['name'].should eql 'dployr'
      end

      it "should exists the lang key" do
        @result.should have_key 'lang'
      end

      it "should have a valid value" do
        @result['lang'].should eql 'ruby'
      end
    end
  end

end
