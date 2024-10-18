require 'spec_helper'

RSpec.describe SpreeCmCommissioner::V2::Operator::LineItemSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:order) { create(:order) }
    let!(:line_item) { create(:line_item, order: order) }
    let!(:guest) { create(:guest, line_item: line_item) }

    subject {
      described_class.new(line_item, include: [
        :order,
        :guests,
      ]).serializable_hash
    }

    it 'returns exact line_item attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :number,
        :name,
        :quantity,
        :options_text,
        :qr_data,
        :kyc_fields,
        :available_social_contact_platforms
      )

      expect(subject[:data][:attributes][:name]).to eq line_item.name
      expect(subject[:data][:attributes][:quantity]).to eq line_item.quantity
      expect(subject[:data][:attributes][:options_text]).to eq line_item.options_text
    end

    it 'returns exact line_item relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :order,
        :guests,
        :variant
      )

      order = subject[:included].find { |item| item[:type] == :order }
      expect(order[:attributes].keys).to contain_exactly(:email, :number, :phone_number, :state, :qr_data, :item_count)

      guest = subject[:included].find { |item| item[:type] == :guest }
      expect(guest[:attributes].keys).to contain_exactly(
        :first_name,
        :last_name,
        :dob,
        :gender,
        :kyc_fields,
        :other_occupation,
        :created_at,
        :updated_at,
        :qr_data,
        :social_contact_platform,
        :social_contact,
        :available_social_contact_platforms,
        :age,
        :emergency_contact,
        :other_organization,
        :expectation,
        :upload_later,
        :address,
        :formatted_bib_number,
        :phone_number,
        :allowed_checkout,
        :require_kyc_field,
        :event_id,
        :seat_number
      )
    end
  end
end
