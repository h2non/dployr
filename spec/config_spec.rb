require 'spec_helper'

describe Dployr::Configure do

  before do
    @config = Dployr::Configure.new
  end

  describe "configuration" do

    describe "default values" do

      let(:defaults) do
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

=begin
      before do
        @config.set_defaults!
      end

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
=end

    end

  end

end
