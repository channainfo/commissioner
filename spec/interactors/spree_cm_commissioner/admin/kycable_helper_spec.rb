require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Admin::KycableHelper do
  describe '#calculate_kyc_value' do

    let(:dummy_class) { Class.new { extend SpreeCmCommissioner::Admin::KycableHelper } }

    let(:params) do
      {
        customer_name: '0',        #2**0  = 1
        customer_gender: '0',      #2**1  = 2
        customer_dob: '0',         #2**2  = 4
        customer_occupation: '0',  #2**3  = 8
        customer_id_card: '0'      #2**4  = 16
      }
    end

    it 'return value 1 if customer_name is selected' do
      params[:customer_name] = '1'  

      expect(dummy_class.calculate_kyc_value(params)).to eq(1)
    end

    it 'return value 2 if customer_gender is selected' do
      params[:customer_gender] = '1'

      expect(dummy_class.calculate_kyc_value(params)).to eq(2)
    end

    it 'return value 4 if customer_dob is selected' do
      params[:customer_dob] = '1'

      expect(dummy_class.calculate_kyc_value(params)).to eq(4)
    end

    it 'return value 8 if customer_occupation is selected' do
      params[:customer_occupation] = '1'

      expect(dummy_class.calculate_kyc_value(params)).to eq(8)
    end

    it 'return value 16 if customer_occupation is selected' do
      params[:customer_id_card] = '1'

      expect(dummy_class.calculate_kyc_value(params)).to eq(16)
    end

    it 'return value 31 if value params is selected' do
      expected_value = 2**0 + 2**1 + 2**2 + 2**3 + 2**4
      params.transform_values! { '1' }

      expect(dummy_class.calculate_kyc_value(params)).to eq(expected_value)
    end
  end
end
