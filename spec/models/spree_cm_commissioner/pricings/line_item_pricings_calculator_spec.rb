require "spec_helper"

RSpec.describe SpreeCmCommissioner::Pricings::LineItemPricingsCalculator do
  let(:pricing_models) { [] }
  let(:pricing_rates) { [] }

  let(:variant) { create(:variant, price: 20, pricing_models: pricing_models, pricing_rates: pricing_rates) }
  let(:line_item) { create(:line_item, variant: variant, quantity: 4) }

  subject do
    described_class.new(line_item: line_item)
  end

  # avoid running callback calculate_pricings after save to avoid recursive in rspec
  before do
    allow_any_instance_of(SpreeCmCommissioner::LineItemDecorator).to receive(:calculate_pricings).and_return(true)
  end

  describe '#call' do
    it 'clears previous pricings, applies new pricings, and update pricings attributes' do
      allow(subject).to receive(:clear_previous_pricings)
      allow(subject).to receive(:apply_pricings)
      allow(subject).to receive(:persist_totals)

      subject.call

      expect(subject).to have_received(:clear_previous_pricings)
      expect(subject).to have_received(:apply_pricings)
      expect(subject).to have_received(:persist_totals)
    end

    context 'when variant has early bird rate & model' do
      let(:quantity_1_rule) { build(:cm_quantity_pricing_rule, quantity: 1) }
      let(:early_bird_rule) { build(:cm_early_bird_pricing_rule, from: Date.current, to: Date.current + 2.days) }

      let(:early_bird_model) { build(:cm_pricing_model, flat_adjustment: 5, pricing_rules: [quantity_1_rule, early_bird_rule]) }
      let(:early_rate) { build(:cm_pricing_rate, price: 13, pricing_rules: [quantity_1_rule, early_bird_rule]) }

      let(:pricing_models) { [early_bird_model] }
      let(:pricing_rates) { [early_rate] }

      before do
        allow(subject).to receive(:booking_date).and_return(Date.current + 1.days)
      end

      it 'save applied rate/model to line items' do
        subject.call

        line_item.reload

        # applied model
        expect(line_item.applied_pricing_models.size).to eq 1
        expect(line_item.applied_pricing_models[0].pricing_model).to eq early_bird_model
        expect(line_item.applied_pricing_models[0].amount).to eq 5 * 4
        expect(line_item.applied_pricing_models[0].quantity).to eq 4

        # applied rates
        expect(line_item.applied_pricing_rates.size).to eq 1
        expect(line_item.applied_pricing_rates[0].pricing_rate).to eq early_rate
        expect(line_item.applied_pricing_rates[0].amount).to eq 13 * 4
        expect(line_item.applied_pricing_rates[0].quantity).to eq 4

        # column updated
        expect(line_item.pricing_rates_amount).to eq(13 * 4)
        expect(line_item.pricing_models_amount).to eq(5 * 4)
        expect(line_item.pricing_subtotal).to eq(13 * 4 + 5 * 4)
      end
    end
  end

  describe '#apply_pricings' do
    context 'when line item is a reservation' do
      before do
        allow(line_item).to receive(:reservation?).and_return(true)
        allow(line_item).to receive(:date_range).and_return([Date.today, Date.tomorrow])
      end

      it 'applies pricings for each date in the date range' do
        expect(subject).to receive(:build_pricing_rates).twice.and_return([])
        expect(subject).to receive(:build_pricing_models).twice.and_return([])

        subject.apply_pricings
      end
    end

    context 'when line item is not a reservation' do
      before do
        allow(line_item).to receive(:reservation?).and_return(false)
      end

      it 'applies pricings without iterating over date range' do
        expect(subject).to receive(:build_pricing_rates).once.and_return([])
        expect(subject).to receive(:build_pricing_models).once.and_return([])

        subject.apply_pricings
      end
    end
  end
end
