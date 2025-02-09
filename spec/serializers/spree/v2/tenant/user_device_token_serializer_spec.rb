require 'spec_helper'

RSpec.describe Spree::V2::Tenant::UserDeviceTokenSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:user_device_token) { create(:cm_device_token) }

    subject(:serialized_data) { described_class.new(user_device_token).serializable_hash }

    it 'returns exact user device token attributes' do
      expect(serialized_data[:data][:attributes].keys).to contain_exactly(
        :user_id,
        :registration_token,
        :client_name,
        :client_version,
        :meta,
        :device_type
      )
    end

    it 'returns correct values for user device token attributes' do
      attributes = serialized_data[:data][:attributes]

      expect(attributes[:user_id]).to eq(user_device_token.user_id)
      expect(attributes[:registration_token]).to eq(user_device_token.registration_token)
      expect(attributes[:client_name]).to eq(user_device_token.client_name)
      expect(attributes[:client_version]).to eq(user_device_token.client_version)
      expect(attributes[:meta].as_json).to eq(user_device_token.meta.as_json)
      expect(attributes[:device_type]).to eq(user_device_token.device_type)
    end
  end
end
