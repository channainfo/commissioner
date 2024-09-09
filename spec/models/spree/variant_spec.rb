require 'spec_helper'

RSpec.describe Spree::Variant, type: :model do
  describe 'validations' do
    context 'saving option values to variants' do
      let(:product_kind_option_type) { create(:option_type, kind: :product, presentation: 'Bathroom & Toiletries', name: 'bathroom-toiletries') }
      let(:normal_option_type)       { create(:option_type, kind: :variant, presentation: 'Capacity', name: 'capacity') }
      let(:product_option_values) {[
        Spree::OptionValue.create(option_type: product_kind_option_type, presentation: "Accessible toilet", name: "accessible-toilet"),
        Spree::OptionValue.create(option_type: product_kind_option_type, presentation: "Adapted bath", name: "adapted-bath"),
        # Spree::OptionValue.create(option_type: product_kind_option_type_, presentation: "Bathrobes", name: "bathrobes"),
        # Spree::OptionValue.create(option_type: product_kind_option_type_, presentation: "Cleaning products", name: "cleaning-products"),
        # Spree::OptionValue.create(option_type: product_kind_option_type_, presentation: "Hair dryer", name: "hair-dryer"),
        # Spree::OptionValue.create(option_type: product_kind_option_type_, presentation: "Mirror", name: "mirror"),
        # Spree::OptionValue.create(option_type: product_kind_option_type_, presentation: "Toiletries", name: "toiletries"),
        # Spree::OptionValue.create(option_type: product_kind_option_type_, presentation: "Towels", name: "towels"),
        # Spree::OptionValue.create(option_type: product_kind_option_type_, presentation: "Walk-in shower", name: "walk-in-shower"),
      ]}

      let(:normal_option_values) {[
        Spree::OptionValue.create(option_type: normal_option_type, presentation: "1 people", name: "1-people"),
        # Spree::OptionValue.create(option_type: normal_option_type, presentation: "2 people", name: "2-people"),
        # Spree::OptionValue.create(option_type: normal_option_type, presentation: "3 people", name: "3-people"),
      ]}

      let(:vendor) { create(:active_vendor, stock_locations: [ create(:stock_location) ]) }
      let(:product) {
        product = create(:base_product, vendor: vendor, option_types: [ product_kind_option_type, normal_option_type ])
        product.reload
      }

      context 'for master variant' do
        it 'saved products option values to master_variant' do
          master_variant = build(
            :master_variant,
            product: product,
            option_values: product_option_values
          )

          expect { master_variant.save! }.not_to raise_error
        end

        # it 'raise error on saving none-master option values to master_variant' do
        #   master_variant = build(
        #     :master_variant,
        #     product: product,
        #     option_values: normal_option_values
        #   )

        #   expect {
        #     master_variant.save!
        #   }.to raise_error(ActiveRecord::RecordInvalid)
        # end
      end

      context 'for normal variant' do
        it 'saved none-master option values to normal_variant' do
          normal_variant = build(
            :base_variant,
            product: product,
            option_values: normal_option_values
          )

          expect { normal_variant.save! }.not_to raise_error
        end

        # it 'raise error on saving master option values to normal_variant' do
        #   normal_variant = build(
        #     :base_variant,
        #     product: product,
        #     option_values: products_option_values
        #   )

        #   expect { normal_variant.save! }.to raise_error(ActiveRecord::RecordInvalid)
        # end
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:variant_guest_card_class).class_name('SpreeCmCommissioner::VariantGuestCardClass') }
    it { is_expected.to have_many(:guest_card_classes).through(:variant_guest_card_class).class_name('SpreeCmCommissioner::GuestCardClass') }
  end

  describe 'callbacks' do
    context '#after_commit' do
      let(:vendor) { create(:active_vendor, name: 'Angkor Hotel', min_price: 10, max_price: 30) }
      let(:state) { create(:state, name: 'Siemreap') }
      let!(:option_type) { create(:option_type, name: 'location', presentation: 'Location', attr_type: 'state_selection') }
      let!(:option_value) { create(:option_value, option_type: option_type, name: state.id) }
      let!(:stock_location) { vendor.stock_locations.first.update(state: state) }
      let!(:product1) { create(:base_product, name: 'Bedroom 1', vendor: vendor, price: 10 ) }
      let!(:product2) { create(:base_product, name: 'Bedroom 2', vendor: vendor, price: 20 ) }
      let!(:product3) { create(:base_product, name: 'Bedroom 3', vendor: vendor, price: 30 ) }

      it 'updates vendor min_price' do
        subject { product1.update(price: 5) }
        expect(vendor.min_price).to eq product1.price
      end

      it 'updates vendor max_price' do
        subject { product3.update(price: 35) }
        expect(vendor.max_price).to eq product3.price
      end

      it 'should not update vendor min_price' do
        subject { product1.update(price: 15) }
        expect(vendor.min_price).to eq product1.price
      end

      it 'should not update vendor max_price' do
        subject { product3.update(price: 25) }
        expect(vendor.max_price).to eq product3.price
      end
    end
  end

  # delivery required will be base entirely on option type
  describe '#delivery_required?' do
    let(:product) { create(:product, product_type: :ecommerce, option_types: [option_type]) }
    let(:option_type) { create(:cm_option_type, :delivery_option) }

    subject { build(:variant, product: product, digitals: [create(:digital)], option_values: [option_value]) }

    context 'when deliver option is "delivery"' do
      let(:option_value) { create(:option_value, name: 'delivery', presentation: 'Delivery', option_type: option_type) }

      it 'returns true' do
        expect(subject.non_digital_ecommerce?).to be false
        expect(subject.delivery_required?).to be true
      end
    end

    context 'when deliver option is "pickup"' do
      let(:option_value) { create(:option_value, name: 'pickup', presentation: 'Pickup', option_type: option_type) }

      it 'returns false' do
        expect(subject.non_digital_ecommerce?).to be false
        expect(subject.delivery_required?).to be false
      end
    end
  end

  describe '#non_digital_ecommerce?' do
    context 'when digital? is false and ecommerce? is true' do
      let(:product) { create(:product, product_type: :ecommerce) }
      subject { build(:variant, product: product, digitals: []) }

      it 'returns true' do
        expect(subject.digital?).to be false
        expect(subject.ecommerce?).to be true
        expect(subject.non_digital_ecommerce?).to be true
      end
    end

    context 'when digital? is true' do
      let(:product) { create(:product, product_type: :ecommerce) }
      subject { build(:variant, product: product, digitals: [create(:digital)]) }

      it 'returns false even variant is ecommerce' do
        expect(subject.ecommerce?).to be true
        expect(subject.digital?).to be true
        expect(subject.non_digital_ecommerce?).to be false
      end
    end

    context 'when ecommerce? is false' do
      let(:product) { create(:product, product_type: :service) }
      subject { build(:variant, product: product, digitals: []) }

      it 'returns false event variant is not digital' do
        expect(subject.ecommerce?).to be false
        expect(subject.digital?).to be false
        expect(subject.non_digital_ecommerce?).to be false
      end
    end
  end

  describe '#discontinued?' do
    let(:product) { create(:product) }
    let(:variant) { create(:variant, product: product) }

    context 'when variant is discontinued' do
      it 'return true' do
        variant.discontinue!

        expect(variant.discontinued?).to be true
      end
    end

    context 'when variant is not discontinued but product is discountinued' do
      it 'return true' do
        product.discontinue!

        expect(variant.discontinued?).to be true
      end
    end

    context 'when both variant, product are not discontinued' do
      it 'return false' do
        expect(variant.discontinued?).to be false
      end
    end
  end
end
