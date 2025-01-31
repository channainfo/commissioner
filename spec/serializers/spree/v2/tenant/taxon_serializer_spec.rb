require 'spec_helper'

RSpec.describe Spree::V2::Tenant::TaxonSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:taxon) { create(:taxon) }

    subject {
      described_class.new(taxon).serializable_hash
    }

    it 'returns exact taxon attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :name,
        :pretty_name,
        :permalink,
        :seo_title,
        :description,
        :from_date,
        :to_date
      )
    end

    it 'returns correct values for taxon attributes' do
      expect(subject[:data][:attributes][:name]).to eq(taxon.name)
      expect(subject[:data][:attributes][:pretty_name]).to eq(taxon.pretty_name)
      expect(subject[:data][:attributes][:permalink]).to eq(taxon.permalink)
      expect(subject[:data][:attributes][:seo_title]).to eq(taxon.seo_title)
      expect(subject[:data][:attributes][:description]).to eq(taxon.description)
      expect(subject[:data][:attributes][:from_date]).to eq(taxon.from_date)
      expect(subject[:data][:attributes][:to_date]).to eq(taxon.to_date)
    end
  end
end
