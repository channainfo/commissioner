require 'spec_helper'

RSpec.describe SpreeCmCommissioner::V2::Storefront::GuestSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:guest) { create(:guest) }

    subject {
      described_class.new(guest, include: [
        :occupation,
        :nationality,
        :id_card,
        :check_in,
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
        :age,
        :emergency_contact,
        :other_organization,
        :expectation,
        :allowed_checkout,
        :upload_later,
      )
    end

    it 'returns exact guest associations' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :occupation,
        :nationality,
        :id_card,
        :check_in
      )
    end
  end
end
