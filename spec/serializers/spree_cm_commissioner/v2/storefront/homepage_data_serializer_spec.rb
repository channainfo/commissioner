# frozen_string_literal: true

RSpec.describe SpreeCmCommissioner::V2::Storefront::HomepageDataSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:banner)  { create(:cm_homepage_banner) }
    let!(:product) { create(:base_product) }
    let!(:brand_taxon) { create(:taxon) }
    let(:home_data_loader) { SpreeCmCommissioner::HomepageDataLoader.new }

    subject {
      described_class.new(home_data_loader).serializable_hash
    }

    it 'does not have attributes' do
      expect(subject[:data][:attributes]).to be nil
    end

    it 'returns exact relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :homepage_banners,
        :featured_vendors,
        :trending_categories
      )
    end
  end
end
