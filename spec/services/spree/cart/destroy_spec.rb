require "spec_helper"

RSpec.describe Spree::Cart::Destroy do
  describe '#void_payments' do
    let(:invalid_payment) { create(:payment, state: :invalid) }
    let(:failed_payment) { create(:payment, state: :failed) }
    let(:completed_payment) { create(:payment, state: :completed) }

    it 'only void payments that payment.can_void? true' do
      allow(invalid_payment).to receive(:can_void?).and_return(false)
      allow(failed_payment).to receive(:can_void?).and_return(false)
      allow(completed_payment).to receive(:can_void?).and_return(true)

      order = create(:order_with_line_items, payments: [
        invalid_payment,
        failed_payment,
        completed_payment
      ])

      described_class.new.send(:void_payments, order: order)

      expect(order.payments[0].state).to eq 'invalid'
      expect(order.payments[1].state).to eq 'failed'
      expect(order.payments[2].state).to eq 'void'
    end
  end
end