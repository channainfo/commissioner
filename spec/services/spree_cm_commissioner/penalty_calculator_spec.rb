require "spec_helper"

RSpec.describe SpreeCmCommissioner::PenaltyCalculator do
  let(:customer) { create(:cm_customer) }

  describe '.calculate_penalty_in_days' do
    it 'returns the penalty length in days' do

      subscription = create(:cm_subscription, customer: customer, start_date: '2023-5-10'.to_date, price: 13.0, month: 1, due_date: 30 )
      due_date = subscription.orders.first.line_items.first.due_date
      current_date = Time.new(2023,06,20,12,0,0) # 20th June 2023
      expected_penalty_in_days = 11
      calculated_penalty = described_class.calculate_penalty_in_days(current_date,due_date)

      expect(calculated_penalty).to eq(expected_penalty_in_days)
    end
  end
end
