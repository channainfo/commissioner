require 'spec_helper'

module SpreeCmCommissioner
  RSpec.describe VariantDecorator, type: :model do
    describe '#permanent_stock?' do
      let(:product) { build(:product, product_type: product_type) }
      let(:variant) { build(:variant, product: product) }

      context 'when product_type is accommodation' do
        let(:product_type) { 'accommodation' }

        before do
          allow(variant).to receive(:accommodation?).and_return(true)
          allow(variant).to receive(:transit?).and_return(false)
        end

        it 'returns true' do
          expect(variant.permanent_stock?).to be true
        end
      end

      context 'when product_type is transit' do
        let(:product_type) { 'transit' }

        before do
          allow(variant).to receive(:accommodation?).and_return(false)
          allow(variant).to receive(:transit?).and_return(true)
        end

        it 'returns true' do
          expect(variant.permanent_stock?).to be true
        end
      end

      context 'when product_type is event' do
        let(:product_type) { 'event' }

        before do
          allow(variant).to receive(:accommodation?).and_return(false)
          allow(variant).to receive(:transit?).and_return(false)
        end

        it 'returns false' do
          expect(variant.permanent_stock?).to be false
        end
      end

      context 'when product_type is something else' do
        let(:product_type) { 'service' }

        before do
          allow(variant).to receive(:accommodation?).and_return(false)
          allow(variant).to receive(:transit?).and_return(false)
        end

        it 'returns false' do
          expect(variant.permanent_stock?).to be false
        end
      end
    end

    describe '#pre_inventory_days' do
      let(:product) { build(:product, product_type: product_type) }
      let(:variant) { build(:variant, product: product) }

      context 'when product_type is transit' do
        let(:product_type) { 'transit' }

        it 'returns 90' do
          expect(variant.pre_inventory_days).to eq(90)
        end
      end

      context 'when product_type is accommodation' do
        let(:product_type) { 'accommodation' }

        it 'returns 365' do
          expect(variant.pre_inventory_days).to eq(365)
        end
      end

      context 'when product_type is event' do
        let(:product_type) { 'event' }

        it 'returns nil' do
          expect(variant.pre_inventory_days).to be_nil
        end
      end

      context 'when product_type is something else' do
        let(:product_type) { 'service' }

        it 'returns nil' do
          expect(variant.pre_inventory_days).to be_nil
        end
      end
    end
  end
end
