require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderStateMachine do
  context 'before_transition :complete' do
    let(:order) { create(:order_with_line_items, state: :address) }

    # make sure order can transition from cart to complete
    before do
      allow(order).to receive(:delivery_required?).and_return(false)
      allow(order).to receive(:payment_required?).and_return(false)
      allow(order).to receive(:confirmation_required?).and_return(false)
    end

    describe '#request' do
      context 'when need confirmation: true' do
        context 'when :request return true' do
          it 'call request & transition to complete' do
            allow(order).to receive(:need_confirmation?).and_return(true)
            allow(order).to receive(:request).and_return(true)
            order.next

            expect(order).to have_received(:request)
            expect(order.state).to eq 'complete'
          end
        end

        context 'when :request return false' do
          it 'call request & keep order state to address' do
            allow(order).to receive(:need_confirmation?).and_return(true)
            allow(order).to receive(:request).and_return(false)
            order.next

            expect(order).to have_received(:request)
            expect(order.state).to eq 'address'
          end
        end
      end

      context 'when need confirmation: false' do
        it 'does not call :request & transition to complete' do
          allow(order).to receive(:need_confirmation?).and_return(false)
          allow(order).to receive(:request).and_return(true)
          order.next!

          expect(order).not_to have_received(:request)
          expect(order.state).to eq 'complete'
        end
      end
    end

    describe '#generate_bib_number' do
      context 'when :generate_bib_number return true' do
        it 'call generate bib_number then transition to complete' do
          allow(order).to receive(:generate_bib_number).and_return(true)
          order.next

          expect(order).to have_received(:generate_bib_number)
          expect(order.state).to eq 'complete'
        end
      end

      context 'when :generate_bib_number return false' do
        it 'call generate bib_number then transition to complete' do
          allow(order).to receive(:generate_bib_number).and_return(false)
          order.next

          expect(order).to have_received(:generate_bib_number)
          expect(order.state).to eq 'address'
        end
      end
    end
  end

  context 'after_transition :complete' do
    let(:order1) { create(:order_with_line_items, state: :address) }
    let(:order2) { create(:order_with_line_items, state: :address) }

    # make sure order can transition from cart to complete
    before do
      allow(order1).to receive(:delivery_required?).and_return(false)
      allow(order1).to receive(:payment_required?).and_return(false)
      allow(order1).to receive(:confirmation_required?).and_return(false)

      allow(order2).to receive(:delivery_required?).and_return(false)
      allow(order2).to receive(:payment_required?).and_return(false)
      allow(order2).to receive(:confirmation_required?).and_return(false)
    end

    describe '#precalculate_conversion' do
      it 'transition to complete & call :precalculate_conversion' do
        # it return true / false, order state still stay the same.
        allow(order1).to receive(:precalculate_conversion).and_return(false)
        allow(order2).to receive(:precalculate_conversion).and_return(true)

        order1.next
        order2.next

        expect(order1).to have_received(:precalculate_conversion)
        expect(order1.state).to eq 'complete'

        expect(order2).to have_received(:precalculate_conversion)
        expect(order2.state).to eq 'complete'
      end
    end

    describe '#notify_order_complete_app_notification_to_user' do
      context 'when subscription?' do
        it 'transition to complete & does not call :notify_order_complete_app_notification_to_user' do
          allow(order1).to receive(:subscription?).and_return(true)
          allow(order1).to receive(:notify_order_complete_app_notification_to_user)
          order1.next

          expect(order1).not_to have_received(:notify_order_complete_app_notification_to_user)
          expect(order1.state).to eq 'complete'
        end
      end

      context 'when not subscription?' do
        it 'transition to complete & call :notify_order_complete_app_notification_to_user' do
          allow(order1).to receive(:subscription?).and_return(false)
          allow(order1).to receive(:notify_order_complete_app_notification_to_user).and_return(true)
          order1.next

          expect(order1).to have_received(:notify_order_complete_app_notification_to_user)
          expect(order1.state).to eq 'complete'
        end
      end
    end

    describe '#notify_order_complete_telegram_notification_to_user' do
      context 'when subscription?' do
        it 'transition to complete & does not call :notify_order_complete_telegram_notification_to_user' do
          allow(order1).to receive(:subscription?).and_return(true)
          allow(order1).to receive(:notify_order_complete_telegram_notification_to_user)
          order1.next

          expect(order1).not_to have_received(:notify_order_complete_telegram_notification_to_user)
          expect(order1.state).to eq 'complete'
        end
      end

      context 'when not subscription?' do
        it 'transition to complete & call :notify_order_complete_telegram_notification_to_user' do
          allow(order1).to receive(:subscription?).and_return(false)
          allow(order1).to receive(:notify_order_complete_telegram_notification_to_user).and_return(true)
          order1.next

          expect(order1).to have_received(:notify_order_complete_telegram_notification_to_user)
          expect(order1.state).to eq 'complete'
        end
      end
    end

    describe '#send_order_complete_telegram_alert_to_vendors' do
      context 'when need_confirmation?' do
        it 'transition to complete & does not call :send_order_complete_telegram_alert_to_vendors' do
          allow(order1).to receive(:need_confirmation?).and_return(true)
          allow(order1).to receive(:send_order_complete_telegram_alert_to_vendors)
          order1.next

          expect(order1).not_to have_received(:send_order_complete_telegram_alert_to_vendors)
          expect(order1.state).to eq 'complete'
        end
      end

      context 'when not need_confirmation?' do
        it 'transition to complete & call :send_order_complete_telegram_alert_to_vendors' do
          allow(order1).to receive(:need_confirmation?).and_return(false)
          allow(order1).to receive(:send_order_complete_telegram_alert_to_vendors).and_return(true)
          order1.next

          expect(order1).to have_received(:send_order_complete_telegram_alert_to_vendors)
          expect(order1.state).to eq 'complete'
        end
      end
    end

    describe '#send_order_complete_telegram_alert_to_store' do
      context 'when need_confirmation?' do
        it 'transition to complete & does not call :send_order_complete_telegram_alert_to_store' do
          allow(order1).to receive(:need_confirmation?).and_return(true)
          allow(order1).to receive(:send_order_complete_telegram_alert_to_store)
          order1.next

          expect(order1).not_to have_received(:send_order_complete_telegram_alert_to_store)
          expect(order1.state).to eq 'complete'
        end
      end

      context 'when not need_confirmation?' do
        it 'transition to complete & call :send_order_complete_telegram_alert_to_store' do
          allow(order1).to receive(:need_confirmation?).and_return(false)
          allow(order1).to receive(:send_order_complete_telegram_alert_to_store).and_return(true)
          order1.next

          expect(order1).to have_received(:send_order_complete_telegram_alert_to_store)
          expect(order1.state).to eq 'complete'
        end
      end
    end
  end

  describe '#around_transition to: :complete' do
    let(:order) { create(:order_with_line_items, line_items_count: 2) }
    let(:line_item_ids) { order.line_items.pluck(:id) }
    let(:inventory_updater) { instance_double(SpreeCmCommissioner::RedisStock::InventoryUpdater) }

    before do
      # Mock Redis stock updater
      allow(SpreeCmCommissioner::RedisStock::InventoryUpdater).to receive(:new).with(line_item_ids).and_return(inventory_updater)
    end

    context 'when sufficient stock is available' do
      before do
        allow(order).to receive(:ensure_line_items_are_in_stock).and_return(true)
        allow(inventory_updater).to receive(:unstock!)

        allow(order).to receive(:finalize!)
        allow(order).to receive(:delivery_required?).and_return(false)
        allow(order).to receive(:payment_required?).and_return(false)
        allow(order).to receive(:confirmation_required?).and_return(false)
      end

      it 'unstocks inventory in Redis and completes the order' do
        order.next
        expect(inventory_updater).to receive(:unstock!).once

        order.next
        expect(order).to have_received(:finalize!)
        expect(order.state).to eq 'complete'
      end
    end

    context 'when sufficient stock is available, and an error occurs during unstock in redis' do
      before do
        allow(order).to receive(:ensure_line_items_are_in_stock).and_return(true)
        allow(inventory_updater).to receive(:unstock!).and_raise(SpreeCmCommissioner::RedisStock::InventoryUpdater::UnableToUnstock)

        allow(order).to receive(:finalize!)
        allow(order).to receive(:delivery_required?).and_return(false)
        allow(order).to receive(:payment_required?).and_return(false)
        allow(order).to receive(:confirmation_required?).and_return(false)
      end

      it 'does not unstock inventory' do
        order.next

        expect{ order.next }.to raise_error(SpreeCmCommissioner::RedisStock::InventoryUpdater::UnableToUnstock)
        expect(order).not_to have_received(:finalize!)
        expect(order.reload.state).not_to eq 'complete'
      end
    end
  end

  describe '#after_transition to: :cancel' do
    let(:order) { create(:completed_order_with_totals) }
    let(:line_item_ids) { order.line_items.pluck(:id) }
    let(:inventory_updater) { instance_double(SpreeCmCommissioner::RedisStock::InventoryUpdater) }

    before do
      allow(SpreeCmCommissioner::RedisStock::InventoryUpdater).to receive(:new).with(line_item_ids).and_return(inventory_updater)
      allow(order).to receive(:delivery_required?).and_return(false)
      allow(order).to receive(:payment_required?).and_return(false)
      allow(order).to receive(:confirmation_required?).and_return(false)
    end

    it 'restocks inventory in Redis' do
      expect(inventory_updater).to receive(:restock!).once
      order.cancel
      expect(order.state).to eq 'canceled'
    end
  end

  describe '#after_transition to: :resume' do
    let(:order) { create(:completed_order_with_totals) }
    let(:line_item_ids) { order.line_items.pluck(:id) }
    let(:inventory_updater) { SpreeCmCommissioner::RedisStock::InventoryUpdater.new(line_item_ids) }

    context 'when sufficient stock is available' do
      before do
        allow(SpreeCmCommissioner::RedisStock::InventoryUpdater).to receive(:new).with(line_item_ids).and_return(inventory_updater)
        allow(inventory_updater).to receive(:restock!)
        allow(inventory_updater).to receive(:unstock!)
        allow(order).to receive(:ensure_line_items_are_in_stock).and_return(true)
        allow(order).to receive(:delivery_required?).and_return(false)
        allow(order).to receive(:payment_required?).and_return(false)
        allow(order).to receive(:confirmation_required?).and_return(false)
      end

      it 'unstocks inventory in Redis' do
        order.cancel

        expect(inventory_updater).to receive(:unstock!).once
        order.resume

        expect(order.completed?).to eq(true)
      end
    end

    context 'when sufficient stock is available, and an error occurs during unstock in redis' do
      before do
        allow(order).to receive(:unstock_inventory_in_redis!).and_raise(SpreeCmCommissioner::RedisStock::InventoryUpdater::UnableToUnstock)

        allow(order).to receive(:ensure_line_items_are_in_stock).and_return(true)
        allow(order).to receive(:delivery_required?).and_return(false)
        allow(order).to receive(:payment_required?).and_return(false)
        allow(order).to receive(:confirmation_required?).and_return(false)
      end

      it 'does not unstock inventory and add log' do
        order.cancel

        expect{order.resume}.to raise_error(SpreeCmCommissioner::RedisStock::InventoryUpdater::UnableToUnstock)
        expect(order.reload.state).not_to eq 'resumed'
      end
    end
  end
end
