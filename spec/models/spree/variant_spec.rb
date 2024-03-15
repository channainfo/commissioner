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

  describe 'callbacks' do
    context '#after_commit' do
      let(:vendor) { create(:active_vendor, name: 'Angkor Hotel', min_price: 10, max_price: 30) }
      let(:state) { create(:state, name: 'Siemreap') }
      let!(:option_type) { create(:option_type, name: 'location', presentation: 'Location', attr_type: 'state_selection') }
      let!(:option_value) { create(:option_value, option_type: option_type, presentation: state.id) }
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

  describe '#number_of_guests' do
    let(:variant) { create(:variant) }

    it 'return 2 of number_of_adults + number_of_kids' do
      allow(variant).to receive(:number_of_adults).and_return(1)
      allow(variant).to receive(:number_of_kids).and_return(1)

      expect(variant.number_of_guests).to eq 2
    end

    it 'return 1 when number_of_adults + number_of_kids less than default' do
      allow(variant).to receive(:number_of_adults).and_return(0)
      allow(variant).to receive(:number_of_kids).and_return(0)

      expect(variant.number_of_guests).to eq 1
      expect(variant.class::DEFAULT_NUMBER_OF_GUESTS).to eq 1
    end
  end

  context 'guests options' do
    let(:product) { create(:product, option_types: [option_type]) }
    subject { create(:variant, product: product, option_values: [option_value]) }

    describe '#number_of_kids' do
      let(:option_type) { create(:cm_option_type, :kids) }
      let(:option_value) { create(:option_value, name: '1-kid', presentation: '1', option_type: option_type) }

      it 'return result in integer' do
        expect(subject.number_of_kids).to eq 1
      end
    end

    describe '#number_of_adults' do
      let(:option_type) { create(:cm_option_type, :adults) }
      let(:option_value) { create(:option_value, name: '2-adults', presentation: '2', option_type: option_type) }

      it 'return result in integer' do
        expect(subject.number_of_adults).to eq 2
      end
    end

    describe '#kids_age_max' do
      let(:option_type) { create(:cm_option_type, :kids_age_max) }
      let(:option_value) { create(:option_value, name: 'max-14-year', presentation: '14', option_type: option_type) }

      it 'return result in integer' do
        expect(subject.kids_age_max).to eq 14
      end
    end

    describe '#allowed_extra_adults' do
      let(:option_type) { create(:cm_option_type, :allowed_extra_adults) }
      let(:option_value) { create(:option_value, name: 'allowed-2-adults', presentation: '2', option_type: option_type) }

      it 'return result of presentation in integer' do
        expect(subject.allowed_extra_adults).to eq 2
      end
    end

    describe '#allowed_extra_kids' do
      let(:option_type) { create(:cm_option_type, :allowed_extra_kids) }
      let(:option_value) { create(:option_value, name: '2-kids', presentation: '2', option_type: option_type) }

      it 'return result of presentation in integer' do
        expect(subject.allowed_extra_kids).to eq 2
      end
    end
  end
end
