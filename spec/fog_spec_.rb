require 'fog'

describe "Fog" do

  describe "compute" do

    before { Fog.mock! }

    after { Fog.unmock! }

    let(:fog) do
      Fog::Compute.new({
        :provider                 => 'AWS',
        :aws_access_key_id        => 'key',
        :aws_secret_access_key    => 'secret'
      })
    end

    describe "create server" do

      before do
        @server = fog.servers.create :flavor_id => 1, :image_id => 'ami-5ee70037', :name => 'fake_server'
        @server.wait_for { ready? }
      end

      it "should create the server" do
        #fog.servers.get(@server.id)should_not be_empty
        fog.servers.all.should have(1).items
      end

      it "should have a valid image id" do
        fog.servers.get(@server.id).image_id.should eql 'ami-5ee70037'
      end

      it "should have a valid dns name" do
        fog.servers.get(@server.id).dns_name.should include("compute-1.amazonaws.com")
      end

      it "should destroy the server" do
        @server.destroy
      end

    end
  end
end
