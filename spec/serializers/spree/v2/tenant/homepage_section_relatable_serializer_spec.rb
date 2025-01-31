require 'spec_helper'

RSpec.describe Spree::V2::Tenant::HomepageSectionRelatableSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:taxon) { create(:taxon) }
    let!(:homepage_section_relatable) { create(:cm_homepage_section_relatable, relatable: taxon) }

    subject {
      described_class.new(homepage_section_relatable, include: [:relatable]).serializable_hash
    }

    it 'returns exact homepage_section_relatable attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :homepage_section_id,
        :position
      )
    end

    it 'returns correct values for homepage_section_relatable attributes' do
      expect(subject[:data][:attributes][:homepage_section_id]).to eq(homepage_section_relatable.homepage_section_id)
      expect(subject[:data][:attributes][:position]).to eq(homepage_section_relatable.position)
    end

    it 'includes relatable relationship' do
      expect(subject[:data][:relationships].keys).to contain_exactly(:relatable)
    end

    it 'includes relatable data' do
      relatable_data = subject[:included].find { |item| item[:type] == :taxon }
      expect(relatable_data[:attributes][:name]).to eq(taxon.name)
      expect(relatable_data[:attributes][:pretty_name]).to eq(taxon.pretty_name)
      expect(relatable_data[:attributes][:permalink]).to eq(taxon.permalink)
      expect(relatable_data[:attributes][:seo_title]).to eq(taxon.seo_title)
      expect(relatable_data[:attributes][:description]).to eq(taxon.description)
    end
  end
end
