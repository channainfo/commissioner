require 'spec_helper'

RSpec.describe Spree::V2::Tenant::PromotionRuleSerializer, type: :serializer do
  describe '#serializable_hash' do
    let(:promotion) { create(:cm_promotion) }
    let(:users) { create_list(:cm_user, 3) }
    let(:promotion_rule) { Spree::Promotion::Rules::User.create(promotion: promotion, user_ids: users.map(&:id)) }

    subject {
      described_class.new(promotion_rule).serializable_hash
    }

    it 'returns exact promotion rule attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :preferences,
        :user_ids,
        :type_name
      )
    end

    it 'returns correct type_name' do
      expect(subject[:data][:attributes][:type_name]).to eq 'spree/promotion/rules/user'
    end

    it 'returns correct user_ids' do
      expect(subject[:data][:attributes][:user_ids]).to contain_exactly(*users.map(&:id))
    end

    it 'returns correct preferences' do
      expect(subject[:data][:attributes][:preferences]).to eq({})
    end
  end
end
