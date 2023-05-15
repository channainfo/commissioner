# frozen_string_literal: true

RSpec.describe SpreeCmCommissioner::V2::Storefront::HomepageDataSerializer, type: :serializer do
  describe '.serializable_hash' do
    let!(:banner)  { create(:cm_homepage_banner) }
    let!(:product) { create(:base_product) }
    let!(:brand_taxon) { create(:taxon) }
    let(:home_data_loader) { SpreeCmCommissioner::HomepageDataLoader.new }

    context 'relationships' do
      subject { described_class.new(home_data_loader).serializable_hash }

      it { expect(subject[:data][:relationships]).to include(:homepage_banners) }
      it { expect(subject[:data][:relationships]).to include(:featured_vendors) }
      it { expect(subject[:data][:relationships]).to include(:trending_categories) }

      # it { expect(subject[:data][:relationships]).to include(:top_categories) }
      # it { expect(subject[:data][:relationships]).to include(:display_products) }
      # it { expect(subject[:data][:relationships]).to include(:featured_brands) }
    end
  end
end
