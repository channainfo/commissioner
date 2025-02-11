require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderUpdaterDecorator, type: :model do
  let(:order) { create(:order) }
  let(:order_updater) { Spree::OrderUpdater.new(order) }

  describe '#update' do
    it 'calls the original update method' do
      expect(order_updater).to receive(:update).and_call_original
      order_updater.update
    end

    it 'calls update_user_cart_item_count after updating the order' do
      expect(order_updater).to receive(:update_user_cart_item_count)
      order_updater.update
    end
  end

  describe '#update_user_cart_item_count' do
    let(:updater_instance) { instance_double(SpreeCmCommissioner::UserCartItemCountUpdater) }

    before do
      allow(SpreeCmCommissioner::UserCartItemCountUpdater).to receive(:new).and_return(updater_instance)
    end

    it 'calls a UserCartItemCountUpdater with the order' do
      expect(updater_instance).to receive(:call).with(order: order)
      order_updater.send(:update_user_cart_item_count)
    end
  end
end
