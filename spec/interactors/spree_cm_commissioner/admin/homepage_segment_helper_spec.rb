require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Admin::HomepageSegmentHelper do
  describe '#calculate_segment_value' do

    let(:dummy_class) { Class.new { extend SpreeCmCommissioner::Admin::HomepageSegmentHelper } }

    let(:params) do
      {
        general: '0',        #2**0  = 1
        ticket: '0',    #2**1  = 2
      }
    end

    it 'return value 1 if general is selected' do
      params[:general] = '1'

      expect(dummy_class.calculate_segment_value(params)).to eq(1)
    end

    it 'return value 2 if ticket is selected' do
      params[:ticket] = '1'

      expect(dummy_class.calculate_segment_value(params)).to eq(2)
    end

    it 'return value 3 if value params is selected' do
      expected_value = 2**0 + 2**1
      params.transform_values! { '1' }

      expect(dummy_class.calculate_segment_value(params)).to eq(expected_value)
    end
  end
end
