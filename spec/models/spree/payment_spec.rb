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
end
