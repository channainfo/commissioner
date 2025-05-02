require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::StockMovementCreator, type: :interactor do
  let(:store) { create(:store) }
  let(:variant) { create(:variant, track_inventory: true) }
  let(:stock_location) { create(:stock_location) }
  let(:stock_item) { create(:stock_item, variant: variant, stock_location: stock_location) }
  let(:permitted_stock_movement_attributes) do
    [:quantity, :stock_item, :stock_item_id, :originator, :action, :originator_type, :originator_id]
  end
  let(:stock_movement_params) do
    ActionController::Parameters.new(
      stock_movement: {
        quantity: 5,
        action: 'add',
        stock_item_id: stock_item.id,
        originator_type: 'Spree::Order',
        originator_id: 1
      }
    ).require(:stock_movement).permit(permitted_stock_movement_attributes)
  end

  let(:context) do
    Interactor::Context.new(
      variant_id: variant.id,
      stock_location_id: stock_location.id,
      current_store: store,
      stock_movement_params: stock_movement_params
    )
  end

  subject(:interactor) { described_class.call(context) }

  describe '#call' do
    before do
      allow(store.variants).to receive(:find).with(variant.id).and_return(variant)
      allow(Spree::StockLocation).to receive(:find).with(stock_location.id).and_return(stock_location)
      allow(stock_location).to receive(:set_up_stock_item).with(variant).and_return(stock_item)
    end

    context 'when the variant tracks inventory' do
      context 'when stock movement is saved successfully' do
        it 'creates and saves a stock movement in the database' do
          expect { interactor }.to change { Spree::StockMovement.count }.by(1)
          expect(interactor).to be_success
          stock_movement = Spree::StockMovement.last
          expect(stock_movement.quantity).to eq(stock_movement_params[:quantity])
          expect(stock_movement.stock_item_id).to eq(stock_item.id)
          expect(stock_movement.action).to eq(stock_movement_params[:action])
          expect(stock_movement.originator_type).to eq(stock_movement_params[:originator_type])
          expect(stock_movement.originator_id).to eq(stock_movement_params[:originator_id])
          expect(interactor.stock_movement).to eq(stock_movement)
        end

        it 'enqueues InventoryItemsAdjusterJob with correct parameters' do
          expect(SpreeCmCommissioner::Stock::InventoryItemsAdjusterJob)
            .to receive(:perform_later).with(variant_id: variant.id, quantity: stock_movement_params[:quantity])
          interactor
        end
      end

      context 'when stock movement fails to save' do
        let(:stock_movement) { instance_double(Spree::StockMovement, save: false, errors: double(full_messages: ['Invalid quantity'])) }

        before do
          allow(stock_location).to receive(:stock_movements).and_return(double(build: stock_movement))
          allow(stock_movement).to receive(:stock_item=).with(stock_item)
        end

        it 'fails the context with error messages' do
          expect(interactor).to be_failure
          expect(interactor.message).to eq('Invalid quantity')
        end

        it 'does not enqueue InventoryItemsAdjusterJob' do
          expect(SpreeCmCommissioner::Stock::InventoryItemsAdjusterJob).not_to receive(:perform_later)
          interactor
        end
      end
    end

    # Other contexts (e.g., when variant does not track inventory) remain unchanged
    context 'when the variant does not track inventory' do
      let(:variant) { create(:variant, track_inventory: false) }

      it 'fails the context with appropriate message' do
        expect(interactor).to be_failure
        expect(interactor.message).to eq(Spree.t(:doesnt_track_inventory))
      end

      it 'does not attempt to create a stock movement' do
        expect(stock_location).not_to receive(:stock_movements)
        interactor
      end

      it 'does not enqueue InventoryItemsAdjusterJob' do
        expect(SpreeCmCommissioner::Stock::InventoryItemsAdjusterJob).not_to receive(:perform_later)
        interactor
      end
    end
  end

  describe 'context attributes' do
    it 'delegates variant_id, stock_location_id, current_store, and stock_movement_params to context' do
      interactor = described_class.new(context)
      expect(interactor.variant_id).to eq(variant.id)
      expect(interactor.stock_location_id).to eq(stock_location.id)
      expect(interactor.current_store).to eq(store)
      expect(interactor.stock_movement_params).to eq(stock_movement_params)
    end
  end
end
