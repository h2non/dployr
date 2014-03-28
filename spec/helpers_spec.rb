require 'spec_helper'

describe Halley::Helper do

  describe :merge do

    describe "multiple hashes with one level" do
      before do
        x = { :a => 10, :b => 20 }
        y = { :a => 100, :c => 200 }
        z = { :c => 300, :d => 400 }
        @result = Halley::Helper.merge x, y, z
      end

      it "should override the :a value" do
        @result[:a].should eq 100
      end

      it "should not merge the :b value" do
        @result[:b].should eq 20
      end

      it "should override the :c value" do
        @result[:c].should eq 300
      end

      it "should override the :c value" do
        @result[:d].should eq 400
      end
    end

  end

end
