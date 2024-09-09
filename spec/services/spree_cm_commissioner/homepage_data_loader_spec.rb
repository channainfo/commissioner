require "spec_helper"

RSpec.describe SpreeCmCommissioner::HomepageDataLoader do
  let!(:background) { create(:cm_homepage_background, :with_app_web_image) }
  let!(:banner) { create(:cm_homepage_banner, :with_app_web_image) }
  let!(:vendor) { create(:vendor) }

  describe '.with_cache' do
    subject {
      config = SpreeCmCommissioner::Configuration.new
      config[:featured_vendor_ids] = vendor.id.to_s

      described_class.with_cache
    }

    it 'returns instance of loaded HomepageDataLoader' do

      expect(subject).to be_a_kind_of(described_class)

      expect(subject.featured_vendors).to be_a_kind_of(ActiveRecord::Relation)
      expect(subject.featured_vendors[0]).to be_a_kind_of(Spree::Vendor)

      expect(subject.homepage_backgrounds).to be_a_kind_of(ActiveRecord::Relation)
      expect(subject.homepage_backgrounds[0]).to be_a_kind_of(SpreeCmCommissioner::HomepageBackground)

      expect(subject.homepage_banners).to be_a_kind_of(ActiveRecord::Relation)
      expect(subject.homepage_banners[0]).to be_a_kind_of(SpreeCmCommissioner::HomepageBanner)
    end
  end
end
