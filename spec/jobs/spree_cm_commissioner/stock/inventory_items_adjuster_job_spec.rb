require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::InventoryItemsAdjusterJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let(:variant) { create(:variant) }
    let(:variant_id) { variant.id }
    let(:quantity) { 10 }
    let(:interactor_result) { instance_double(Interactor::Context, success?: true) }

    before do
      # Mock the interactor call
      allow(SpreeCmCommissioner::Stock::InventoryItemsAdjuster).to receive(:call).and_return(interactor_result)
    end

    it 'finds the variant by variant_id' do
      expect(Spree::Variant).to receive(:find).with(variant_id).and_return(variant)
      subject.perform(variant_id: variant_id, quantity: quantity)
    end

    it 'calls InventoryItemsAdjuster with the correct variant and quantity' do
      expect(SpreeCmCommissioner::Stock::InventoryItemsAdjuster).to receive(:call).with(variant: variant, quantity: quantity)
      subject.perform(variant_id: variant_id, quantity: quantity)
    end

    context 'when the interactor succeeds' do
      before do
        allow(interactor_result).to receive(:success?).and_return(true)
      end

      it 'performs the job without raising an error' do
        expect { subject.perform(variant_id: variant_id, quantity: quantity) }.not_to raise_error
      end
    end

    context 'when the interactor raises an error' do
      before do
        allow(SpreeCmCommissioner::Stock::InventoryItemsAdjuster).to receive(:call)
          .and_raise(ActiveRecord::RecordInvalid)
      end

      it 'raises the error' do
        expect { subject.perform(variant_id: variant_id, quantity: quantity) }
          .to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when the variant is not found' do
      before do
        allow(Spree::Variant).to receive(:find).with(variant_id).and_raise(ActiveRecord::RecordNotFound)
      end

      it 'raises ActiveRecord::RecordNotFound' do
        expect { subject.perform(variant_id: variant_id, quantity: quantity) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe '#perform_later' do
      it 'enqueues the job with correct arguments' do
        expect {
          described_class.perform_later(variant_id: variant_id, quantity: quantity)
        }.to enqueue_job(SpreeCmCommissioner::Stock::InventoryItemsAdjusterJob)
          .with(variant_id: variant_id, quantity: quantity)
      end
    end
  end
end
