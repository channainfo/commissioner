require 'spec_helper'

RSpec.describe SpreeCmCommissioner::JsonLd::VendorSerializer, type: :serializer do
  describe '#serializable_hash' do
    let(:vendor) { create(:vendor) }

    subject {
      described_class.new(vendor, include: [
        :image
      ]).serializable_hash
    }

    it 'returns exact vendor attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :name,
        :about_us,
        :slug,
        :contact_us,
        :min_price,
        :max_price,
        :star_rating,
        :short_description,
        :full_address,
        :image_id
      )
    end

    it 'returns exact vendor relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :image
      )
    end
  end
end
