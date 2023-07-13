RSpec.describe SpreeCmCommissioner::V2::Storefront::HomepageDataSerializer, type: :serializer do
  describe '#serializable_hash' do
    before(:all) {
      create(:cm_homepage_background, :with_app_web_image)
      create(:cm_homepage_banner, :with_app_web_image)
    }
    
    let(:home_data_loader) { SpreeCmCommissioner::HomepageDataLoader.new.call }
    
    subject {
      described_class.new(home_data_loader, include: [
        :homepage_backgrounds,
        :homepage_banners,
        :featured_vendors,
        :trending_categories
        ]).serializable_hash
      }
      
      
      it 'does not have attributes' do
        expect(subject[:data][:attributes]).to be nil
      end
      
      
      it 'returns exact relationships' do
        expect(subject[:data][:relationships].keys).to contain_exactly(
          :homepage_backgrounds,
          :homepage_banners,
          :featured_vendors,
          :trending_categories
        )
      end
      
      it 'returns [include] with homepage backgrounds' do
        homepage_backgrounds = subject[:included].filter { |item| item[:type] == :homepage_background }
        
        expect(homepage_backgrounds.size).to eq 1
        expect(homepage_backgrounds[0][:type]).to eq :homepage_background
        expect(homepage_backgrounds[0].keys).to contain_exactly(:id, :type, :attributes, :relationships)
        expect(homepage_backgrounds[0][:relationships].keys).to contain_exactly(:app_image, :web_image)
      end
      
      it 'returns [include] with homepage banners' do
        homepage_banners = subject[:included].filter { |item| item[:type] == :homepage_banner }
        
        expect(homepage_banners.size).to eq 1
        expect(homepage_banners[0][:type]).to eq :homepage_banner
        expect(homepage_banners[0].keys).to contain_exactly(:id, :type, :attributes, :relationships)
        expect(homepage_banners[0][:relationships].keys).to contain_exactly(:app_image, :web_image)
      end
    end
  end
  