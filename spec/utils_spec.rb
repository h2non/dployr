require 'spec_helper'
require 'dployr/utils'

describe Dployr::Utils do

  describe :has do

    context "when exists" do
      let(:hash) {
        { "key" => "val", :key => "another" }
      }

      it "should exist a string key" do
        Dployr::Utils.has(hash, 'key').should be_true
      end

      it "should exist a symbol key" do
        Dployr::Utils.has(hash, :key).should be_true
      end
    end

    context "when not exists" do
      it "should exist a string key" do
        Dployr::Utils.has(hash, 'key').should be_false
      end

      it "should exist a symbol key" do
        Dployr::Utils.has(hash, :key).should be_false
      end
    end
  end

  describe :get_by_key do
    context "when exists" do
      let(:hash) {
        { "key" => "val", :key => "another", :str => "text" }
      }

      it "should get a value by string key" do
        Dployr::Utils.get_by_key(hash, 'key').should eql "val"
      end

      it "should get a value by symbol key" do
        Dployr::Utils.get_by_key(hash, :key).should eql "another"
      end

      it "should get a value by symbol key" do
        Dployr::Utils.get_by_key(hash, "str").should eql "text"
      end
    end

    context "when not exists" do
      it "should get a value by string key" do
        Dployr::Utils.get_by_key({}, 'key').should eql nil
      end

      it "should get a value by symbol key" do
        Dployr::Utils.get_by_key({}, :key).should eql nil
      end
    end
  end

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

    describe "nested hashes with strings and arrays" do
      before do
        x = { :a => 10, :b => { :a => [1], :b => "b" } }
        y = { :a => 100, :b => { :a => [2,3], :c => "c" } }
        @result = Dployr::Utils.merge x, y
      end

      it "should override the :a value" do
        @result[:a].should eq 100
      end

      context "merge :b" do
        subject { @result[:b] }
        it { should be_a Hash }
        it { should have(2).items }
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
        @result = Dployr::Utils.template "%{salutation}, my name is %{name}", data
      end

      it "should replace both values" do
        @result.should eql "Hi, my name is "
      end
    end

  end

end