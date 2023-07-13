require "spec_helper"

RSpec.describe SpreeCmCommissioner::HomepageDataLoader do
  before(:all) {
    background = create(:cm_homepage_background, :with_app_web_image)
    banner = create(:cm_homepage_banner, :with_app_web_image)
    vendor = create(:vendor)
    
    config = SpreeCmCommissioner::Configuration.new
    config[:featured_vendor_ids] = vendor.id.to_s
  }
  
  describe '.with_cache' do
    it 'returns instance of loaded HomepageDataLoader' do
      result = described_class.with_cache
      
      expect(result).to be_a_kind_of(described_class)
      
      expect(result.featured_vendors).to be_a_kind_of(ActiveRecord::Relation)
      expect(result.featured_vendors[0]).to be_a_kind_of(Spree::Vendor)
      
      expect(result.homepage_backgrounds).to be_a_kind_of(ActiveRecord::Relation)
      expect(result.homepage_backgrounds[0]).to be_a_kind_of(SpreeCmCommissioner::HomepageBackground)
      
      expect(result.homepage_banners).to be_a_kind_of(ActiveRecord::Relation)
      expect(result.homepage_banners[0]).to be_a_kind_of(SpreeCmCommissioner::HomepageBanner)
    end
  end
end
