require 'spec_helper'

RSpec.describe Spree::Payment, type: :model do
  describe '#current_user_instance' do
    let(:user1) { create(:user) }
    let(:user2) { create(:admin_user) }
    let(:user3) { create(:admin_user) }
    let(:order) { create(:order_with_line_items) }
    let(:payment) { create(:payment, amount: order.total, order: order) }

    it 'save current_user_instace to state_change' do
      payment.current_user_instance = user1
      payment.complete!
      payment.reload

      expect(payment.state_changes.size).to eq 1
      expect(payment.state_changes[0].user).to eq user1
    end

    it 'save current_user_instace to payable if completed' do
      payment.current_user_instance = user1
      payment.complete!
      payment.reload

      expect(payment.payable).to eq user1
    end

    it 'does not save current_user_instace if not set' do
      payment.complete!
      payment.reload

      expect(payment.payable).to eq nil
      expect(payment.state_changes.size).to eq 1
      expect(payment.state_changes[0].user).to eq nil
    end

    it 'save state_change.user differently base on current_user_instance' do
      payment.current_user_instance = user1
      payment.pend!

      payment.current_user_instance = user2
      payment.complete!

      payment.current_user_instance = user3
      payment.void!

      expect(payment.payable).to eq user2

      expect(payment.state_changes.size).to eq 3
      expect(payment.state_changes[0].user).to eq user1
      expect(payment.state_changes[1].user).to eq user2
      expect(payment.state_changes[2].user).to eq user3
    end
  end

  describe '#process!' do
    context 'when payment receive manually' do
      let(:payment_method) { create(:check_payment_method) }
      subject { create(:check_payment, state: 'checkout', payment_method: payment_method) }

      it 'complete payment during process directly' do
        allow(subject).to receive(:payment_receive_manually?).and_return(true)
        expect(subject).to receive(:complete!).and_call_original

        subject.process!

        expect(subject.state).to eq 'completed'
      end
    end

    context 'when payment not receive manually' do
      let(:payment_method) { create(:check_payment_method) }
      subject { create(:check_payment, state: 'checkout', payment_method: payment_method) }

      it 'does not complete the payment & just call super' do
        allow(subject).to receive(:payment_receive_manually?).and_return(false)
        expect(subject).not_to receive(:complete!)

        subject.process!
      end
    end
  end

  describe '#payment_receive_manually?' do
    let(:role) { create(:role, name: 'ticket_seller') }
    let(:user) { create(:user , phone_number: '012290564', spree_roles: [role]) }
    let(:order) { create(:order, user: user) }

    let(:payment_method) { create(:check_payment_method, auto_capture: true) }
    subject { create(:check_payment, state: 'checkout', payment_method: payment_method, order: order) }

    context 'when payment is check, auto capture and user is ticket seller' do
      it 'return payment_receive_manually? true' do
        expect(subject.check_payment_method?).to be true
        expect(subject.payment_method.auto_capture?).to be true
        expect(subject.order.ticket_seller_user?).to be true

        expect(subject.payment_receive_manually?).to be true
      end
    end

    context 'when payment method is not check' do
      it 'return payment_receive_manually? false' do
        allow(subject).to receive(:check_payment_method?).and_return(false)
        allow(subject.payment_method).to receive(:auto_capture?).and_return(true)
        allow(subject.order).to receive(:ticket_seller_user?).and_return(true)

        expect(subject.payment_receive_manually?).to be false
      end
    end

    context 'when payment method is not auto_capture' do
      it 'return payment_receive_manually? false' do
        allow(subject).to receive(:check_payment_method?).and_return(true)
        allow(subject.payment_method).to receive(:auto_capture?).and_return(false)
        allow(subject.order).to receive(:ticket_seller_user?).and_return(true)

        expect(subject.payment_receive_manually?).to be false
      end
    end

    context 'when user is not ticket seller' do
      it 'return payment_receive_manually? false' do
        allow(subject).to receive(:check_payment_method?).and_return(true)
        allow(subject.payment_method).to receive(:auto_capture?).and_return(true)
        allow(subject.order).to receive(:ticket_seller_user?).and_return(false)

        expect(subject.payment_receive_manually?).to be false
      end
    end
  end
end
