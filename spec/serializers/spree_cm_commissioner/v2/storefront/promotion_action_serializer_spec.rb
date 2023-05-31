# frozen_string_literal: true

RSpec.describe SpreeCmCommissioner::V2::Storefront::PromotionActionSerializer, type: :serializer do
  describe '.serializable_hash' do
    let(:promotion) { create(:promotion) }
    let(:calculator) { Spree::Calculator::FlatPercentItemTotal.new(preferred_flat_percent: 10) }
    let(:promotion_action) { Spree::Promotion::Actions::CreateAdjustment.create(promotion: promotion, calculator: calculator) }

    subject {
      described_class.new(promotion_action, include: [
        :calculator,
      ]).serializable_hash
    }

    it 'returns exact promotion attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :type_name,
      )
    end

    it 'returns exact promotion relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :calculator,
      )
    end

    context 'calculator' do
      it 'return serialized flat_percent_item_total caculator' do
        calculator = subject[:included].find { |item| item[:type] == :calculator }
        preferences = calculator[:attributes][:preferences]

        expect(calculator[:attributes].keys).to contain_exactly(:preferences, :type_name)
        expect(calculator[:attributes][:type_name]).to eq 'spree/calculator/flat_percent_item_total'
        expect(calculator[:attributes][:preferences][:flat_percent]).to eq 10
      end
    end
  end
end
