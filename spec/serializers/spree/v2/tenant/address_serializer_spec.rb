require 'spec_helper'

RSpec.describe Spree::V2::Tenant::AddressSerializer, type: :serializer do
  describe '#serializable_hash' do
    let(:cm_country) { create(:cm_country) }
    let(:cm_state) { create(:cm_state, country: cm_country) }
    let(:cm_address) { create(:cm_address, state: cm_state, country: cm_country) }

    subject(:serialized_data) { described_class.new(cm_address).serializable_hash }

    it 'returns exact address attributes' do
      expect(serialized_data[:data][:attributes].keys).to contain_exactly(
        :firstname, :lastname, :address1, :address2, :city, :zipcode, :phone,
        :state_name, :company, :country_name, :country_iso3, :country_iso,
        :label, :public_metadata, :age, :gender, :state_code
      )
    end

    it 'serializes the correct values' do
      attributes = serialized_data[:data][:attributes]

      expect(attributes[:firstname]).to eq(cm_address.firstname)
      expect(attributes[:lastname]).to eq(cm_address.lastname)
      expect(attributes[:address1]).to eq(cm_address.address1)
      expect(attributes[:address2]).to eq(cm_address.address2)
      expect(attributes[:city]).to eq(cm_address.city)
      expect(attributes[:zipcode]).to eq(cm_address.zipcode)
      expect(attributes[:phone]).to eq(cm_address.phone)
      expect(attributes[:state_name]).to eq(cm_state.name)
      expect(attributes[:state_code]).to eq(cm_state.abbr)
      expect(attributes[:company]).to eq(cm_address.company)
      expect(attributes[:country_name]).to eq(cm_country.name)
      expect(attributes[:country_iso3]).to eq(cm_country.iso3)
      expect(attributes[:country_iso]).to eq(cm_country.iso)
      expect(attributes[:label]).to eq(cm_address.label)
      expect(attributes[:public_metadata].as_json).to eq(cm_address.public_metadata.as_json)
      expect(attributes[:age]).to eq(cm_address.age)
      expect(attributes[:gender]).to eq(cm_address.gender)
    end
  end
end
