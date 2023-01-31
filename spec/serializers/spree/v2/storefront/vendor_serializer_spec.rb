# frozen_string_literal: true

RSpec.describe Spree::V2::Storefront::VendorSerializer, type: :serializer do
  describe '.serializable_hash' do
    let(:vendor) { create(:cm_vendor_with_products, :with_all_relationships) }

    subject {
      described_class.new(vendor, include: [
        :image,
        :products,
        :stock_locations,
        :variants,
        :photos,
        :vendor_kind_option_types,
        :promoted_option_types,
        :logo
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
      )
    end

    it 'returns exact vendor relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :image,
        :logo,
        :photos,
        :products,
        :promoted_option_types,
        :stock_locations,
        :variants,
        :vendor_kind_option_types,
      )
    end

    it 'returns exact vendor includes' do
      expect(subject[:included].pluck(:type)).to contain_exactly(
        :vendor_image,
        :product, :product,
        :stock_location,
        :variant, :variant, :variant, :variant,
        :photo,
        :option_type, :option_type,
        :vendor_logo
      )
    end

    context 'relationships in include' do
      it 'returns image' do
        vendor_image = subject[:included].select {|e| e[:type] == :vendor_image}
        expect(vendor_image.size).to eq 1
        expect(vendor_image.first[:id]).to eq vendor.image.id.to_s
      end
  
      it 'returns products' do
        products = subject[:included].select {|e| e[:type] == :product}
        expect(products.size).to eq 2
        expect(products.pluck(:id)).to eq vendor.products.map {|e| e.id.to_s }
      end
  
      it 'returns stock_locations' do
        stock_locations = subject[:included].select {|e| e[:type] == :stock_location}
        expect(stock_locations.size).to eq 1
        expect(stock_locations.pluck(:id)).to eq vendor.stock_locations.map {|e| e.id.to_s }
      end
  
      it 'returns variants' do
        variants = subject[:included].select {|e| e[:type] == :variant}
        expect(variants.size).to eq 4
        expect(variants.pluck(:id)).to eq vendor.variants.map {|e| e.id.to_s }
      end
  
      it 'returns photos' do
        photos = subject[:included].select {|e| e[:type] == :photo}
        expect(photos.size).to eq 1
        expect(photos.pluck(:id)).to eq vendor.photos.map {|e| e.id.to_s }
      end
  
      it 'returns vendor_kind_option_types' do
        option_types = subject[:included].select {|e| e[:type] == :option_type}
        expect(option_types.size).to eq 2
        expect(option_types.pluck(:id)).to eq vendor.vendor_kind_option_types.map {|e| e.id.to_s }
      end
  
      it 'returns promoted_option_types' do
        option_types = subject[:included].select {|e| e[:type] == :option_type && e[:attributes][:promoted] == true}
        expect(option_types.size).to eq 1
        expect(option_types.pluck(:id)).to eq vendor.promoted_option_types.map {|e| e.id.to_s }
      end
  
      it 'returns logo' do
        logo = subject[:included].select {|e| e[:type] == :vendor_logo }
        expect(logo.size).to eq 1
        expect(logo.first[:id]).to eq vendor.logo.id.to_s
      end
    end
  end
end
