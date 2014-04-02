require 'spec_helper'
require 'dployr/utils'

describe Dployr::Utils do

  describe :merge do

    describe "multiple hashes with one level" do
      before do
        x = { :a => 10, :b => 20 }
        y = { :a => 100, :c => 200 }
        z = { :c => 300, :d => 400 }
        @result = Dployr::Utils.merge x, y, z
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

  describe :replace_values do
    describe "replacement using hash" do
      let(:data) {
        { :name => "John" }
      }

      before do
        @result = Dployr::Utils.replace_values "My name is %{name}", data
      end

      it "should replace the name" do
        @result.should eql "My name is John"
      end
    end

    describe "non existent values" do
      let(:data) {
        { :salutation => "Hi" }
      }

      it "should replace raise an error if value do not exists" do
        begin
          @result = Dployr::Utils.template "%{salutation}, my name is %{name}", data
        rescue Exception => e
          e.should_not be_empty
        end
      end
    end
  end

  describe :template do
    describe "replacement using hash" do
      let(:data) {
        { :name => "John" }
      }

      before do
        @result = Dployr::Utils.template "My name is %{name}", data
      end

      it "should replace the name" do
        puts @result.to_s
        @result.should eql "My name is John"
      end
    end

    describe "multiple values" do
      let(:data) {
        { :name => "John", :salutation => "Hi" }
      }

      before do
        @result = Dployr::Utils.template "%{salutation}, my name is %{name}", data
      end

      it "should replace both values" do
        @result.should eql "Hi, my name is John"
      end
    end

    describe "non existent values" do
      let(:data) {
        { :salutation => "Hi" }
      }

      before do
        begin
          @result = Dployr::Utils.template "%{salutation}, my name is %{name}", data
        rescue Exception => e
          puts e.to_s
        end
      end

      it "should replace both values" do
        @result.should eql "Hi, my name is "
      end
    end

  end

end
