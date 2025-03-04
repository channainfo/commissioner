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
end
