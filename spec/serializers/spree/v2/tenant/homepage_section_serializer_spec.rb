require 'spec_helper'

RSpec.describe Spree::V2::Tenant::HomepageSectionSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:homepage_section) { create(:cm_homepage_section) }
    let!(:homepage_section_relatable) { create(:cm_homepage_section_relatable, homepage_section: homepage_section, relatable: create(:taxon)) }

    subject {
      described_class.new(homepage_section, include: [:homepage_section_relatables]).serializable_hash
    }

    it 'returns exact homepage_section attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :id,
        :title,
        :segments,
        :description,
        :active,
        :position,
        :created_at,
        :updated_at
      )
    end

    it 'returns correct values for homepage_section attributes' do
      expect(subject[:data][:attributes][:id]).to eq(homepage_section.id)
      expect(subject[:data][:attributes][:title]).to eq(homepage_section.title)
      expect(subject[:data][:attributes][:segments]).to eq(homepage_section.segments)
      expect(subject[:data][:attributes][:description]).to eq(homepage_section.description)
      expect(subject[:data][:attributes][:active]).to eq(homepage_section.active)
      expect(subject[:data][:attributes][:position]).to eq(homepage_section.position)
      expect(subject[:data][:attributes][:created_at]).to eq(homepage_section.created_at)
      expect(subject[:data][:attributes][:updated_at]).to eq(homepage_section.updated_at)
    end

    it 'includes homepage_section_relatables relationship' do
      expect(subject[:data][:relationships].keys).to contain_exactly(:homepage_section_relatables)
    end

    it 'includes homepage_section_relatables data' do
      relatable_data = subject[:included].find { |item| item[:type] == :homepage_section_relatable }
      expect(relatable_data[:attributes][:homepage_section_id]).to eq(homepage_section_relatable.homepage_section_id)
      expect(relatable_data[:attributes][:position]).to eq(homepage_section_relatable.position)
    end
  end
end
