require 'spec_helper'

RSpec.describe Spree::V2::Tenant::GuestSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:guest) { create(:guest) }

    subject {
      described_class.new(guest, include: [
        :occupation,
        :nationality,
      ]).serializable_hash
    }

    it 'returns exact guest attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :first_name,
        :last_name,
        :dob,
        :gender,
        :kyc_fields,
        :other_occupation,
        :created_at,
        :updated_at,
        :qr_data,
        :age,
        :social_contact_platform,
        :social_contact,
        :emergency_contact,
        :other_organization,
        :expectation,
        :allowed_checkout,
        :upload_later,
        :available_social_contact_platforms,
        :allowed_upload_later,
        :address,
        :formatted_bib_number,
        :phone_number,
        :require_kyc_field,
        :user_id
      )
      expect(subject[:data][:attributes][:qr_data]).to eq guest.token
    end

    it 'returns exact guest associations' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :occupation,
        :nationality,
        :id_card
      )
    end
  end
end
