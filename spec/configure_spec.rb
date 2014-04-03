require 'spec_helper'

describe Dployr::Configure do

  before do
    @config = Dployr::Configure.new
  end

  describe "configuration" do

    describe "default values" do
      let(:defaults) do
        {
          :attributes => {
            :name => "example",
            :instance_type => "m1.small"
          },
          :scripts => [
            "path" => "configure.sh"
          ],
          :providers => {
            :aws => {
              :attributes => {
                "instance_type" => "m1.small"
              },
              :scripts => [
                "path" => "router.sh"
              ],
              :regions => {
                "eu-west-1a" => {
                  :attributes => [
                    "keypair" => "vagrant-aws-ireland"
                  ]
                }
              }
            }
          }
        }
      end

      describe "add default values" do
        before do
          @config.set_default defaults
        end

        context "when was added" do
          it "should create a default instance" do
            @config.default.should be_an_instance_of Dployr::Config::Instance
          end

          it "should have valid attributes" do
            @config.default.attributes.should be_a Hash
            @config.default.attributes.should have(2).items
          end

          it "should have scripts" do
            @config.default.scripts.should be_a Array
            @config.default.scripts.should have(1).items
          end

          it "should have providers" do
            @config.default.providers.should be_a Hash
            @config.default.providers.should have(1).items
          end

          it "should provider must be for AWS" do
            @config.default.get_provider(:aws).should be_a Hash
          end
        end
      end
    end

    describe "instance" do
      let(:machine) do
        {
          :attributes => {
            :name => "machine",
            :instance_type => "m1.small"
          },
          :scripts => [
            "path" => "setup.sh"
          ],
          :providers => {
            :aws => {
              :attributes => [
                "instance_type" => "m1.small"
              ],
              :regions => [
                "europe-west1-a" => {
                  :attributes => [
                    "keypair" => "vagrant-aws-ireland"
                  ]
                }
              ]
            }
          }
        }
      end

      describe "add new instance" do
        before do
          @instance = @config.add_instance 'zeus', machine
        end

        context "when was added" do
          it "should exists the new instance" do
            @instance.should be_an_instance_of Dployr::Config::Instance
          end

          it "should have valid attributes" do
            @instance.attributes.should be_a Hash
            @instance.attributes.should have(2).items
          end

          it "should have scripts" do
            @instance.scripts.should be_a Array
            @instance.scripts.should have(1).items
          end

          it "should have providers" do
            @instance.providers.should be_a Hash
            @instance.providers.should have(1).items
          end

          it "should provider must be for AWS" do
            @instance.get_provider(:aws).should be_a Hash
          end
        end
      end
    end

  end
end
