require 'spec_helper'

describe Dployr::Configure do

  config = Dployr::Configure.new

  describe "setting config" do
    describe "default values" do
      let(:defaults) do
        {
          attributes: {
            name: "example",
            instance_type: "m1.small"
          },
          scripts: [
            { path: "configure.sh" }
          ],
          providers: {
            aws: {
              attributes: {
                network_id: "be457fca",
                instance_type: "m1.small"
              },
              scripts: [
                { path: "router.sh" }
              ],
              regions: {
                "eu-west-1a" => {
                  attributes: {
                    keypair: "vagrant-aws-ireland"
                  }
                }
              }
            }
          }
        }
      end

      describe "add default values" do
        before do
          config.set_default defaults
        end

        context "when was added" do
          it "should create a default instance" do
            config.default.should be_an_instance_of Dployr::Config::Instance
          end

          it "should have valid attributes" do
            config.default.attributes.should be_a Hash
            config.default.attributes.should have(2).items
          end

          it "should have scripts" do
            config.default.scripts.should be_a Array
            config.default.scripts.should have(1).items
          end

          it "should have providers" do
            config.default.providers.should be_a Hash
            config.default.providers.should have(1).items
          end

          it "should provider must be for AWS" do
            config.default.get_provider(:aws).should be_a Hash
          end
        end
      end
    end

    describe "instance" do
      settings = {
        attributes: {
          name: "zeus"
        },
        authentication: {
          user: "admin",
          key_path: "path/to/key.pem"
        },
        scripts: [
          { path: "setup.sh", remote: true }
        ],
        providers: {
          aws: {
            attributes: {
              instance_type: "m1.small"
            },
            regions: {
              "europe-west1-a" => {
                attributes: {
                  keypair: "vagrant-aws-ireland"
                }
              }
            }
          }
        }
      }

      before :all do
        config.add_instance :zeus, settings
      end

      describe "add new instance" do
        let(:instance) { config.get_instance :zeus }

        context "when was added" do
          it "should exists the new instance" do
            instance.should be_an_instance_of Dployr::Config::Instance
          end

          it "should have valid attributes" do
            instance.attributes.should be_a Hash
            instance.attributes.should have(1).items
          end

          it "should have scripts" do
            instance.scripts.should be_a Array
            instance.scripts.should have(1).items
          end

          it "should have providers" do
            instance.providers.should be_a Hash
            instance.providers.should have(1).items
          end

          it "should provider must be for AWS" do
            instance.get_provider(:aws).should be_a Hash
          end
        end
      end
    end

    describe "getting config" do
      let(:zeus) { config.get_config :zeus }

      it "should exists and be a valid" do
        zeus.should be_a Hash
      end

      describe "attributes" do
        it "shoudl exists" do
          zeus[:attributes].should be_a Hash
        end

        it "should overwrite the name" do
          zeus[:attributes][:name].should eql 'zeus'
        end

        it "should have the default instance type" do
          zeus[:attributes][:instance_type].should eql 'm1.small'
        end
      end

      describe "scripts" do
        it "should exists" do
          zeus[:scripts].should be_a Array
        end

        it "should have the default script" do
          zeus[:scripts][0][:path].should eql 'configure.sh'
        end

        it "should have the instance specific script" do
          zeus[:scripts][1][:path].should eql 'setup.sh'
        end
      end

      describe "autentication" do
        it "should exists" do
          zeus[:authentication].should be_a Hash
        end

        it "should have a valid number of values" do
          zeus[:authentication].should have(2).items
        end

        it "should have a valid authentication values" do
          zeus[:authentication][:user].should eql 'admin'
        end
      end

      describe "providers" do
        it "should exists" do
          zeus[:providers].should be_a Hash
          zeus[:providers].should have(1).items
        end

        it "should exists the aws provider config" do
          zeus[:providers][:aws].should be_a Hash
        end

        describe "aws" do
          it "should have the expected values" do
            zeus[:providers][:aws].should have(3).items
          end

          describe "attributes" do
            it "should have valid attributes" do
              zeus[:providers][:aws][:attributes].should be_a Hash
            end

            it "should have a valid number of attributes" do
              zeus[:providers][:aws][:attributes].should have(3).items
            end

            it "should have a valid instance_type" do
              zeus[:providers][:aws][:attributes][:instance_type].should eql "m1.small"
            end

            it "should have a valid netword_id" do
              zeus[:providers][:aws][:attributes][:network_id].should eql "be457fca"
            end

            it "should have a valid name" do
              zeus[:providers][:aws][:attributes][:name].should eql "zeus"
            end
          end

          describe "regions" do
            it "should have valid regions" do
              zeus[:providers][:aws][:regions].should be_a Hash
            end

            it "should have a valid number of providers" do
              zeus[:providers][:aws][:regions].should have(2).items
            end

            it "should exists an europe-west1-a region" do
              zeus[:providers][:aws][:regions]["europe-west1-a"].should be_a Hash
            end

            it "should exists an eu-west-1a region" do
              zeus[:providers][:aws][:regions]["eu-west-1a"].should be_a Hash
            end

            it "should exists an europe-west1-a region" do
              zeus[:providers][:aws][:regions]["eu-west-1a"].should be_a Hash
            end

            describe "region config" do
              let(:attributes) {
                zeus[:providers][:aws][:regions]["eu-west-1a"][:attributes]
              }

              it "should have attributes" do
                attributes.should be_a Hash
              end
            end
          end
        end

      end
    end
  end
end
