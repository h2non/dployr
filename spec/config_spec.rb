require 'spec_helper'

describe Halley::Config do

  before :each do
    puts "Run spec"
  end

  it "should expose the read method" do
    Halley::Config.respond_to?(:read).should be_true
  end

  it "should read the file contents" do
    Halley::Config.read(File.dirname(__FILE__) + '/fixtures/config.yml').should have(1).item
  end

end
