require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CustomerPromotionCreator do
  let(:customer) { create(:cm_customer) }
  let(:store) { create(:store) }
  describe '.call' do
    context "when customer could not be found" do
      it "returns a failure" do
        non_existing_customer_id = 10
        result = described_class.call(customer_id: non_existing_customer_id, reason: '2 building are under construction', discount_amount: 100000, store: store)
        expect(result.success?).to eq false
      end
    end

    context "when customer has no existing promotion" do
      it "creates a new promotion" do
        result = described_class.call(customer_id: customer.id, reason: '2 building are under construction', discount_amount: 100000, store: store)
        promotions = Spree::Promotion.all
        expect(result.success?).to eq true
        expect(promotions.count).to  eq 1
        expect(promotions.first.code).to eq customer.number
      end
    end
    context 'when customer already have existing promotion' do
      before do
        described_class.call(customer_id: customer.id, reason: 'Before calling the class', discount_amount: 100000, store: store)
      end
      it 'updates the existing promotion' do
        result  = described_class.call(customer_id: customer.id, reason: 'After calling the class', discount_amount: 100000, store: store)
        promotions = Spree::Promotion.all
        expect(result.success?).to eq true
        expect(promotions.count).to eq 1
        expect(promotions.first.name).to eq 'After calling the class'
      end
    end
  end
end
