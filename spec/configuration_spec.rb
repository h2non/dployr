require 'spec_helper'

describe Dployr::Configuration do

  config = Dployr::Configuration.new

  describe "setting config" do
    before :all do
      ENV['DPLOYR'] = '0.1.0'
    end

    after :all do
      ENV.delete 'DPLOYR'
    end

    describe "default values" do
      defaults = {
        attributes: {
          name: "example",
          instance_type: "m1.small",
          version: "${DPLOYR}"
        },
        scripts: [
          { path: "configure.sh" }
        ],
        providers: {
          aws: {
            attributes: {
              network_id: "be457fca",
              instance_type: "m1.small",
              "type-%{name}" => "small",
              mixed: "%{network_id}-%{instance_type}"
            },
            scripts: [
              {
                path: "router.sh",
                args: [ "%{name}", "${region}", "${provider}" ]
              }
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
            config.default.attributes.should have(3).items
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

      hera_config = {
        attributes: {
          name: "hera"
        },
        providers: {
          gce: {
            attributes: {
              instance_type: "m1.large"
            },
            regions: {
              "los-angeles-ca" => {
                attributes: {
                  keypair: "google"
                }
              }
            }
          }
        }
      }

      zeus_config = {
        extends: "hera",
        attributes: {
          name: "zeus"
        },
        scripts: [
          { path: "setup.sh", args: ["--id ${index}", "--name ${name}", "%{name}-%{instance_type}-%{version}"], remote: true }
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
        config.add_instance :hera, hera_config
        config.add_instance :zeus, zeus_config
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

        it "should have a valid number" do
          zeus[:scripts].should have(2).items
        end

        it "should have the default script" do
          zeus[:scripts][0][:path].should eql 'configure.sh'
        end

        it "should have the instance specific script" do
          zeus[:scripts][1][:path].should eql 'setup.sh'
        end
      end

      describe "providers" do
        it "should exists" do
          zeus[:providers].should be_a Hash
          zeus[:providers].should have(2).items
        end

        it "should exists the aws provider config" do
          zeus[:providers][:aws].should be_a Hash
        end

        describe "inherited from parent" do
          it "should exists the gce provider config" do
            zeus[:providers][:gce].should be_a Hash
          end

          describe "gce" do
            let(:gce) {
              zeus[:providers][:gce]
            }

            it "should have a valid number of attributes" do
              gce[:attributes].should have(3).items
            end

            it "should have the instance_type attributes" do
              gce[:attributes][:instance_type].should eql "m1.large"
            end

            it "should have valid number of regions" do
              gce[:regions].should have(1).items
            end

            it "should have a valid region" do
              gce[:regions]["los-angeles-ca"].should be_a Hash
            end

            describe "los-angeles-ca region" do
              let(:region) {
                gce[:regions]["los-angeles-ca"]
              }

              it "should have a valid number of attributes" do
                region[:attributes].should have(4).items
              end

              it "should have inherited scripts" do
                region[:scripts].should have(2).items
              end
            end
          end

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
              zeus[:providers][:aws][:attributes].should have(6).items
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

            describe "templating" do
              it "should have a version attribute" do
                zeus[:providers][:aws][:attributes][:version].should eql "0.1.0"
              end

              it "should have a type key with valid replacement" do
                zeus[:providers][:aws][:attributes]["type-zeus"].should eql "small"
              end

              it "should have a mixed attribute with self-referenced values" do
                zeus[:providers][:aws][:attributes][:mixed].should eql "be457fca-m1.small"
              end
            end
          end

          describe "scripts" do
            it "should exists" do
              zeus[:providers][:aws][:scripts].should be_a Array
            end

            it "should have a valid number" do
              zeus[:providers][:aws][:scripts].should have(3).items
            end

            it "should have a valid path" do
              zeus[:providers][:aws][:scripts][0][:path].should eql "configure.sh"
            end

            it "should have a valid path" do
              zeus[:providers][:aws][:scripts][1][:path].should eql "setup.sh"
            end

            it "should have a valid number of arguments" do
              zeus[:providers][:aws][:scripts][1][:args].should have(3).items
            end

            it "should have a remote property" do
              zeus[:providers][:aws][:scripts][1][:remote].should eql true
            end

            it "should have a valid path" do
              zeus[:providers][:aws][:scripts][2][:path].should eql "router.sh"
            end

            describe "templating" do
              it "should replace the argument with the instance name" do
                zeus[:providers][:aws][:scripts][2][:args][0].should eql "zeus"
              end

              it "should replace the name context value" do
                zeus[:providers][:aws][:scripts][1][:args][1].should eql "--name zeus"
              end
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

            describe "europe-west1-a" do
              let(:region) {
                zeus[:providers][:aws][:regions]["eu-west-1a"]
              }

              describe "attributes" do
                it "should exists" do
                  region[:attributes].should be_a Hash
                end

                it "should have the name attribute" do
                  region[:attributes][:name].should eql "zeus"
                end

                it "should have the instance_type attribute" do
                  region[:attributes][:instance_type].should eql "m1.small"
                end

                it "should have the network_id attribute" do
                  region[:attributes][:network_id].should eql "be457fca"
                end

                it "should have the keypair attribute" do
                  region[:attributes][:keypair].should eql "vagrant-aws-ireland"
                end
              end

              describe "scripts" do
                it "should exists" do
                  region[:scripts].should be_a Array
                end

                it "should have a valid number" do
                  region[:scripts].should have(3).items
                end

                it "should have the proper first script" do
                  region[:scripts][0][:path].should eql "configure.sh"
                end

                it "should have the proper second script" do
                  region[:scripts][1][:path].should eql "setup.sh"
                end

                it "should have a valid index argument" do
                  region[:scripts][1][:args][0].should eql "--id "
                end

                it "should have the proper third script" do
                  region[:scripts][2][:path].should eql "router.sh"
                end

                describe "templating" do
                  it "should replace the argument with the current region" do
                    region[:scripts][2][:args][1].should eql "eu-west-1a"
                  end

                  it "should replace the argument with the current provider" do
                    region[:scripts][2][:args][2].should eql "aws"
                  end
                end
              end
            end
          end
        end
      end
    end

    describe "get instance config" do
      attributes = { name: "hera" }

      describe "provider" do
        before :all do
          @config = config.get_provider :zeus, :aws, attributes
        end

        it "should exists the config" do
          @config.should be_a Hash
        end

        it "should have a valid number of keys" do
          @config.should have(3).items
        end

        it "should have two regions" do
          @config[:regions].should have(2).items
        end

        describe "attributes" do
          it "should exists" do
            @config[:attributes].should be_a Hash
          end

          it "should have a valid name" do
            @config[:attributes][:name].should eql "hera"
          end
        end

        describe "scripts" do
          it "should exists" do
            @config[:scripts].should be_a Array
          end

          it "should have a valid number" do
            @config[:scripts].should have(3).items
          end

          it "should overwrite the argument" do
            @config[:scripts][2][:args][0].should eql "hera"
          end
        end
      end

      describe "region" do
        before :all do
          @config = config.get_region :zeus, :aws, "eu-west-1a", attributes
        end

        it "should exists" do
          @config.should be_a Hash
        end

        it "should have a valid number of keys" do
          @config.should have(2).items
        end

        it "should have a attributes" do
          @config[:attributes].should be_a Hash
        end

        it "should have a attributes" do
          @config[:attributes].should be_a Hash
        end
      end
    end
  end
end
