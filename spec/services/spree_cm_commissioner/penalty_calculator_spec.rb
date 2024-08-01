require "spec_helper"

RSpec.describe SpreeCmCommissioner::PenaltyCalculator do
  let(:customer) { create(:cm_customer, last_invoice_date:'2024-06-14' ) }

  describe '.calculate_penalty_in_days' do
    before do
      allow_any_instance_of(SpreeCmCommissioner::Subscription).to receive(:date_within_range).and_return(true)
    end
    it 'returns the penalty length in days' do
      subscription = create(:cm_subscription, customer: customer, start_date: '2024-06-14'.to_date, price: 13.0, month: 1, due_date: 15, quantity: 1 )
      SpreeCmCommissioner::SubscriptionsOrderCreator.call(customer: customer)
      due_date = subscription.orders.first.line_items.last.due_date
      current_date = Time.new(2024,8,01,12,0,0) # 01st August 2024
      expected_penalty_in_days = 3
      calculated_penalty = described_class.calculate_penalty_in_days(current_date,due_date)

      expect(calculated_penalty).to eq(expected_penalty_in_days)
    end
  end
end
