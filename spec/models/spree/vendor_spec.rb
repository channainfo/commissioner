require 'spec_helper'

RSpec.describe Spree::Vendor, type: :model do
  describe 'associations' do
    it { should have_one(:logo).class_name('SpreeCmCommissioner::VendorLogo').dependent(:destroy) }
    it { should have_many(:photos).class_name('SpreeCmCommissioner::VendorPhoto').dependent(:destroy) }
    it { should have_many(:nearby_places).class_name('SpreeCmCommissioner::VendorPlace').dependent(:destroy) }
    it { should have_many(:places).class_name('SpreeCmCommissioner::Place').through(:nearby_places) }
    it { should have_many(:vendor_option_types).class_name('SpreeCmCommissioner::VendorOptionType') }
    it { should have_many(:option_value_vendors).class_name('SpreeCmCommissioner::OptionValueVendor') }
    it { should have_many(:option_values).class_name('Spree::OptionValue').through(:products) }
    it { should have_many(:option_types).class_name('Spree::OptionType').through(:vendor_option_types) }
    it { should have_many(:promoted_option_types).class_name('Spree::OptionType').through(:vendor_option_types) }
    it { should have_many(:vendor_promotion_rules).class_name('SpreeCmCommissioner::VendorPromotionRule') }
    it { should have_many(:promotion_rules).class_name('Spree::PromotionRule').through(:vendor_promotion_rules) }
    it { should have_many(:promotions).class_name('Spree::Promotion').through(:promotion_rules) }
    it { should have_many(:active_promotions).class_name('Spree::Promotion').through(:promotion_rules).source(:promotion) }
    it { should have_many(:possible_promotions).class_name('Spree::Promotion').through(:promotion_rules).source(:promotion) }
    it { should have_many(:auto_apply_promotions).class_name('Spree::Promotion').through(:promotion_rules).source(:promotion) }
  end

  describe 'validations' do
    subject { create(:vendor) }

    it { should validate_numericality_of(:commission_rate).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:commission_rate).is_less_than_or_equal_to(100) }
    it { should validate_presence_of(:commission_rate) }
  end

  describe 'attributes' do
    it { should define_enum_for :primary_product_type }
    it { expect(described_class.primary_product_types.keys).to match(SpreeCmCommissioner::ProductType::PRODUCT_TYPES.map(&:to_s)) }
  end

  describe 'searchkick' do
    # it 'has searchkick_index' do
    #   expect(described_class.searchkick_index).to be_a(Searchkick::Index)
    # end

    it 'has .search method' do
      expect(described_class).to respond_to(:search)
    end

    context '#search_data' do
      let(:vendor) { described_class.new }
      let(:subject) { vendor.search_data }

      it 'includes required fields' do
        expect(subject.keys).to eq [:id, :name, :slug, :active, :min_price, :max_price, :created_at, :updated_at, :presentation]
      end
    end
  end

  describe '.by_vendor_id!' do
    it 'return vendor by slug or id' do
      vendor = create(:vendor, slug: 'vendor')

      result1 = described_class.by_vendor_id!(vendor.slug)
      result2 = described_class.by_vendor_id!(vendor.id)

      expect(result1.id).to eq vendor.id
      expect(result2.id).to eq vendor.id
    end

    it 'raise error when id in int not found' do
      vendor = create(:vendor, slug: 'vendor')
      expect { described_class.by_vendor_id!(1000) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raise error when id in slug-from not found' do
      vendor = create(:vendor, slug: 'vendor')
      expect { described_class.by_vendor_id!('wrong-vendor-slug') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#auto_apply_promotions' do
    let(:vendor) { create(:vendor) }

    it 'should return a promotion where path & code is nil and not expired' do
      promotion = create(:cm_promotion, :with_vendor_rule, vendor: vendor, path: nil, code: nil, expires_at: 1.day.from_now)
      vendor.reload

      expect(vendor.auto_apply_promotions).to eq [promotion]
      expect(promotion.path).to be_nil
      expect(promotion.code).to be_nil
      expect(promotion.expired?).to be false
    end

    it 'should return empty when it expired' do
      promotion = create(:cm_promotion, :with_vendor_rule, vendor: vendor, path: nil, code: nil, expires_at: 1.day.ago)
      vendor.reload

      expect(vendor.auto_apply_promotions).to be_empty
      expect(promotion.expired?).to be true
    end

    it 'should return empty when it has path' do
      promotion = create(:cm_promotion, :with_vendor_rule, vendor: vendor, path: 'page/path', code: nil)
      vendor.reload

      expect(vendor.auto_apply_promotions).to be_empty
      expect(promotion.path).not_to be_nil
    end

    it 'should return empty when it has code' do
      promotion = create(:cm_promotion, :with_vendor_rule, vendor: vendor, path: nil, code: 'coupon-code')
      vendor.reload

      expect(vendor.auto_apply_promotions).to be_empty
      expect(promotion.code).not_to be_nil
    end
  end

  describe '#primary_product_type' do
    it 'raise error on enter invalid primary_product_type' do
      expect{create(:vendor, primary_product_type: :fake)}
        .to raise_error(ArgumentError)
        .with_message("'fake' is not a valid primary_product_type")
    end

    it 'raise error when input product_type instead of primary_product_type' do
      expect{create(:vendor, product_type: :fake)}.to raise_error { |error|
        expect(error).to be_a(NoMethodError)
        expect(error.message).to include('undefined method `product_type=')
      }
    end

    it 'save on input valid primary_product_type' do
      vendor = build(:vendor, primary_product_type: described_class.primary_product_types[0])
      expect(vendor.save!).to be true
    end
  end

  describe '#promoted_option_value_ids' do
    let!(:option_type1) { create(:option_type, promoted: true, kind: :vendor) }
    let!(:option_value1) { create(:option_value, option_type: option_type1) }
    let!(:vendor) { create(:vendor, option_types: [option_type1]) }

    it 'return vendor promoted option values' do
      create(:cm_option_value_vendor, vendor: vendor, option_value: option_value1)
      vendor.reload

      expect(vendor.promoted_option_value_ids).to eq [option_value1.id]
    end

    it 'return vendor promoted option values' do
      option_value1 = create(:option_value, option_type: option_type1)
      option_value2 = create(:option_value, option_type: option_type1)

      vendor = create(:vendor, option_types: [option_type1])

      create(:cm_option_value_vendor, vendor: vendor, option_value: option_value1)
      vendor.reload

      expect(vendor.promoted_option_value_ids).to eq [option_value1.id]
    end
  end

  describe '#update' do
    let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
    let(:siem_reap) { create(:state, name: 'Siem Reap') }
    let!(:vendor) { create(:vendor, total_inventory: 0, default_state_id: phnom_penh.id)  }
    let!(:stock_location) { vendor.stock_locations.first }
    let!(:product1) { create(:product, vendor: vendor)}
    let!(:product2) { create(:product, vendor: vendor)}
    let!(:variant1) { create(:base_variant, product: product1, permanent_stock: 5, price: 20)}
    let!(:variant2) { create(:base_variant, product: product2, permanent_stock: 5, price: 30)}

    context '#update_total_inventory' do
      it 'should update total inventory' do
        vendor.update_total_inventory
        expect(vendor.total_inventory).to eq 12 # master_variant has 1 item each by default
      end
    end

    context '#update_min_max_price' do
      it 'should update min max price ' do
        variant3 = create(:base_variant, product: product2, permanent_stock: 5, price: 10)
        vendor.update_min_max_price

        expect(vendor.min_price.to_f).to eq 10.0
        expect(vendor.max_price.to_f).to eq 30.0
      end

      it 'should update min and max price the same value when min price 0' do
        vendor = create(:vendor, min_price: 0, max_price: 0)
        product = create(:base_product, vendor: vendor, price: 40)

        vendor.update_min_max_price

        expect(vendor.min_price.to_f).to eq 40.0
        expect(vendor.max_price.to_f).to eq 40.0
      end

      it 'should update min and max price to 0' do
        vendor = create(:vendor, min_price: 0, max_price: 0)
        product1 = create(:base_product, vendor: vendor, price: 0)
        product2 = create(:base_product, vendor: vendor, price: 0)

        vendor.update_min_max_price

        expect(vendor.min_price.to_f).to eq 0
        expect(vendor.max_price.to_f).to eq 0
      end
    end

    context '#update_location' do
      it 'should update location ' do
        stock_location.update(state_id: siem_reap.id)

        subject { vendor.update_location }
        expect(vendor.default_state_id).to eq siem_reap.id
      end
    end
  end
end