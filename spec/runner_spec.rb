require 'spec_helper'

describe "Fog::Runner" do
  describe "basic" do

    let(:attrs) {
      { :flavor_id => 1, :image_id => 'ami-5ee70037', :name => 'fake_server' }
    }

    it "should create basic tests" do
      Dployr::Server.new do |s|
        s.set attrs
        #puts s.get.to_s
      end
    end

  end
end
