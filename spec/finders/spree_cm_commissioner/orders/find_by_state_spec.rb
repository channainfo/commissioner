require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Orders::FindByState do
  let!(:user) { create(:user) }
  let!(:order1) { create(:order, state: 'cart', user: user) }
  let!(:order2) { create(:order, state: 'payment', user: user) }
  
  describe 'orders#execute' do
    context 'state' do
      it 'return order payment state' do
        result = SpreeCmCommissioner::Orders::FindByState.new(
          user: user,
          store: nil,
          state: :payment
        ).execute
        
        expect(result.is_a?(ActiveRecord::AssociationRelation)).to be true
        expect(result.size).to eq 1
        expect(result[0].number).to eq order2.number
      end
    end
  end
end
