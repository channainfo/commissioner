require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Admin::KycableHelper do
  describe '#calculate_kyc_value' do

    let(:dummy_class) { Class.new { extend SpreeCmCommissioner::Admin::KycableHelper } }

    let(:params) do
      {
        guest_name: '0',        #2**0  = 1
        guest_gender: '0',      #2**1  = 2
        guest_dob: '0',         #2**2  = 4
        guest_occupation: '0',  #2**3  = 8
        guest_id_card: '0'      #2**4  = 16
      }
    end

    it 'return value 1 if guest_name is selected' do
      params[:guest_name] = '1'

      expect(dummy_class.calculate_kyc_value(params)).to eq(1)
    end

    it 'return value 2 if guest_gender is selected' do
      params[:guest_gender] = '1'

      expect(dummy_class.calculate_kyc_value(params)).to eq(2)
    end

    it 'return value 4 if guest_dob is selected' do
      params[:guest_dob] = '1'

      expect(dummy_class.calculate_kyc_value(params)).to eq(4)
    end

    it 'return value 8 if guest_occupation is selected' do
      params[:guest_occupation] = '1'

      expect(dummy_class.calculate_kyc_value(params)).to eq(8)
    end

    it 'return value 16 if guest_occupation is selected' do
      params[:guest_id_card] = '1'

      expect(dummy_class.calculate_kyc_value(params)).to eq(16)
    end

    it 'return value 31 if value params is selected' do
      expected_value = 2**0 + 2**1 + 2**2 + 2**3 + 2**4
      params.transform_values! { '1' }

      expect(dummy_class.calculate_kyc_value(params)).to eq(expected_value)
    end
  end
end
