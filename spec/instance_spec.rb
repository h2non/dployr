require 'spec_helper'

describe Halley::Config::Instance do

  describe "Instance" do

    describe "instance configuration" do

      let(:instance) {
        Halley::Config::Instance.new
      }

      describe "setting attributes" do

        context "when created" do
          subject { instance.attributes }
          it { should be_a Hash }
          it { should have(0).items }
        end

        context "when add attributes" do
          before do
            instance.set_attributes({ :key => "value" })
          end

          subject { instance.attributes }
          it { should have_key(:key) }
        end

      end

      describe "setting providers" do

        context "when created" do
          subject { instance.providers }
          it { should be_a Array }
          it { should have(0).items }
        end

        describe "setting providers" do

          let(:provider) do
            {
              :aws => {
                :attributes => [
                  :instance_type => "m1.small"
                ],
                :scripts => [],
                :regions => []
              }
            }
          end

          context "when add a provider" do
            before do
              instance.add_provider provider
            end

            it "should add a new provider" do
              puts instance.get_provider(0).has_key? :aws
            end

            subject { instance.get_provider(0) }
            it {
              should be_a Hash
              should have_key :aws
            }

            context "when provider exists" do
              subject { instance.get_provider(0)[:aws] }
              it { should be_a Hash }
              it { should have_key(:attributes) }
              it { should have_key(:scripts) }
              it { should have_key(:regions) }
            end
          end

        end

      end

    end

  end

end
