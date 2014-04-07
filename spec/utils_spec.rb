require 'spec_helper'
require 'dployr/utils'

describe Dployr::Utils do

  describe :has do
    context "when exists" do
      let(:hash) {
        { key: "val", key: "another" }
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
        { "key" => "val", key: "another", "str" => "text" }
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
        x = { a: 10, b: 20 }
        y = { a: 100, c: 200 }
        z = { c: 300, d: 400 }
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
        x = { a: 10, b: { a: [1], b: "b" } }
        y = { a: 100, b: { a: [2,3], c: "c" } }
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

  describe :parse_matrix do
    describe "replacement using hash" do
      data = "name=dployr ; lang = ruby"

      before do
        @result = Dployr::Utils.parse_matrix data
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
        @result = Dployr::Utils.parse_flags data
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

  describe :replace_env_vars do
    describe "environment variable" do
      before :all do
        ENV['DPLOYR'] = 'sample value'
      end

      before :all do
        @result = Dployr::Utils.replace_env_vars "Env var: ${DPLOYR}"
      end

      after :all do
        ENV.delete 'DPLOYR'
      end

      it "should replace the name" do
        @result.should eql "Env var: sample value"
      end
    end

    describe "nonexistent" do
      before :all do
        @result = Dployr::Utils.replace_env_vars "Env var: ${NONEXISTENT}"
      end

      it "should replace the name" do
        @result.should eql "Env var: "
      end
    end
  end

  describe :replace_placeholders do
    describe "replacement using hash" do
      let(:data) {
        { name: "John" }
      }

      before do
        @result = Dployr::Utils.replace_placeholders "My name is %{name}", data
      end

      it "should replace the name" do
        @result.should eql "My name is John"
      end
    end

    describe "non existent values" do
      let(:data) {
        { salutation: "Hi" }
      }

      it "should replace raise an error if value do not exists" do
        begin
          @result = Dployr::Utils.replace_placeholders "%{salutation}, my name is %{name}", data
        rescue Exception => e
          e.should be_instance_of KeyError
        end
      end
    end
  end

  describe :template do
    describe "replacement using hash" do
      let(:data) {
        { name: "John" }
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
        { name: "John", salutation: "Hi" }
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
        { salutation: "Hi" }
      }

      it "should raise an exception error if do not exist the variable" do
        begin
          @result = Dployr::Utils.template "%{salutation}, my name is %{name}", data
        rescue Exception => e
          e.should be_instance_of ArgumentError
        end
      end
    end
  end

  describe :traverse_map do
    describe "multi-type hash" do
      let(:hash) {
        {
          text: { name: "My name is %{name}" },
          array: [ "Another %{name}", { type: "%{type}"} ],
          nonexistent: "this is %{name}"
        }
      }

      let(:values) {
        { name: "Beaker", type: "muppet" }
      }

      before do
        @result = Dployr::Utils.traverse_map(hash) do |str|
          Dployr::Utils.template str, values
        end
      end

      it "should replace the name" do
        @result[:text][:name].should eql "My name is Beaker"
      end

      it "should replace the value in an array" do
        @result[:array][0].should eql "Another Beaker"
      end

      it "should replace the value from the nested hash in array" do
        @result[:array][1][:type].should eql "muppet"
      end

      it "should remove nonexistent template values" do
        @result[:nonexistent].should eql "this is Beaker"
      end
    end
  end

end
