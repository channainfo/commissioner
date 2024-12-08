# frozen_string_literal: true

RSpec.describe SpreeCmCommissioner::V2::Storefront::PromotionSerializer, type: :serializer do
  describe '#serializable_hash' do
    let(:promotion) { create(:promotion_with_item_total_rule) }

    subject {
      described_class.new(promotion, include: [
        :promotion_rules,
        :promotion_actions,
      ]).serializable_hash
    }

    it 'returns exact promotion attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :name,
        :description,
        :match_policy,
        :advertise,
        :expires_at,
      )
    end

    it 'returns exact promotion relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :promotion_actions,
        :promotion_rules
      )
    end

    context 'promotion_rules' do
      it 'return serialized item_total rule' do
        promotion_rules = subject[:included].select { |item| item[:type] == :promotion_rule }
        promotion_rule = promotion_rules.first

        expect(promotion_rules.size).to eq 1
        expect(promotion_rule[:attributes][:type_name]).to eq 'spree/promotion/rules/item_total'
        expect(promotion_rule[:attributes][:preferences].keys).to contain_exactly(:amount_max, :operator_max, :amount_min, :operator_min)
      end
    end
  end
end
