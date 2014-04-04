require 'spec_helper'

describe Dployr::Config::Instance do
  describe "Instance" do
    describe "instance configuration" do
      let(:instance) {
        Dployr::Config::Instance.new
      }

      describe "setting attributes" do
        context "when created" do
          subject { instance.attributes }
          it { should be_a Hash }
          it { should have(0).items }
        end

        context "when add attributes" do
          before do
            instance.set_attribute :key, "value"
          end

          subject { instance.attributes }
          it { should have_key(:key) }
        end
      end

      describe "setting providers" do
        context "when created" do
          subject { instance.providers }
          it { should be_a Hash }
          it { should have(0).items }
        end

        describe "setting providers" do
          let(:provider) do
            {
              attributes: {
                instance_type: "m1.small"
              },
              scripts: [],
              regions: {}
            }
          end

          context "when add a provider" do
            before do
              instance.add_provider :aws, provider
            end

            subject { instance.get_provider :aws }
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
