require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Pricings::LineItemPricingsCalculator do
  include GuestOptionsHelper

  let(:pricing_models) { [] }
  let(:pricing_rates) { [] }

  let(:variant) { create(:variant, price: 20, pricing_models: pricing_models, pricing_rates: pricing_rates) }
  let(:line_item) { create(:line_item, variant: variant, quantity: 1) }

  subject { described_class.new(line_item: line_item) }

  describe '#call' do
    it 'applies new pricings, update pricings attributes & delete previous pricings' do
      allow(subject).to receive(:apply_pricings)
      allow(subject).to receive(:persist_totals)
      allow(subject).to receive(:delete_previous_pricings)

      subject.call

      expect(subject).to have_received(:apply_pricings)
      expect(subject).to have_received(:persist_totals)
      expect(subject).to have_received(:delete_previous_pricings)
    end

    context 'when persist pricings fails' do
      let(:pricing_rate) { build(:cm_pricing_rate, price: 50) }
      let(:pricing_model) { build(:cm_pricing_model, percent_adjustment: 10) }

      let(:variant) { create(:variant, price: 20, pricing_rates: [pricing_rate], pricing_models: [pricing_model]) }
      let(:line_item) { create(:line_item, variant: variant, quantity: 1, pricing_rates_amount: 10, pricing_models_amount: 2, pricing_subtotal: 12) }

      let!(:previous_rate) { line_item.applied_pricing_rates.create!(pricing_rate: pricing_rate, amount: 10) }
      let!(:previous_model) { line_item.applied_pricing_models.create!(pricing_model: pricing_model, amount: 4) }

      it 'rollback, keep old pricing & previous rate, model' do
        allow(subject).to receive(:persist_totals).and_raise(ActiveRecord::RecordInvalid)

        expect { subject.call }.to raise_error(ActiveRecord::RecordInvalid)

        line_item.reload

        expect(line_item.pricing_rates_amount).to eq 10
        expect(line_item.pricing_models_amount).to eq 2
        expect(line_item.pricing_subtotal).to eq 12

        expect(previous_rate.reload).to eq previous_rate
        expect(previous_model.reload).to eq previous_model
      end
    end
  end

  describe '#apply_pricings' do
    context 'when line item is a reservation' do
      let(:date_range) { [Date.today, Date.tomorrow] }

      before do
        allow(line_item).to receive(:reservation?).and_return(true)
        allow(line_item).to receive(:date_range).and_return(date_range)
      end

      it 'iterate over date range & build rates, model for each date' do
        expect(subject).to receive(:build_pricing_rates).with(date_options: date_options_klass.new(date_index: 0, date_range: date_range)).once
        expect(subject).to receive(:build_pricing_models).with(date_options: date_options_klass.new(date_index: 0, date_range: date_range)).once

        expect(subject).to receive(:build_pricing_rates).with(date_options: date_options_klass.new(date_index: 1, date_range: date_range)).once
        expect(subject).to receive(:build_pricing_models).with(date_options: date_options_klass.new(date_index: 1, date_range: date_range)).once

        subject.apply_pricings
      end
    end

    context 'when line item is not a reservation' do
      before do
        allow(line_item).to receive(:reservation?).and_return(false)
      end

      it 'build rates/model without iterating over date range' do
        expect(subject).to receive(:build_pricing_rates).with(date_options: nil).once
        expect(subject).to receive(:build_pricing_models).with(date_options: nil).once

        subject.apply_pricings
      end
    end
  end

  describe '#persist_totals' do
    let(:pricing_rate) { build(:cm_pricing_rate) }
    let(:pricing_model) { build(:cm_pricing_model, flat_adjustment: 10) }

    let(:pricing_rates) { [pricing_rate] }
    let(:pricing_models) { [pricing_model] }

    context 'when model is positive' do
      before do
        line_item.applied_pricing_rates.create!(pricing_rate: pricing_rate, amount: 10)
        line_item.applied_pricing_rates.create!(pricing_rate: pricing_rate, amount: 5)

        line_item.applied_pricing_models.create!(pricing_model: pricing_model, amount: 3)
        line_item.applied_pricing_models.create!(pricing_model: pricing_model, amount: 4)
      end

      it 'recalcaulate total base on applied rate and model' do
        expect {
          subject.persist_totals
          line_item.reload
        }.to change { line_item.pricing_rates_amount }.from(nil).to(15)
         .and change { line_item.pricing_models_amount }.from(nil).to(3 + 4)
         .and change { line_item.pricing_subtotal }.from(nil).to(15 + 7)
      end
    end

    context 'when model is negative' do
      before do
        line_item.applied_pricing_rates.create!(pricing_rate: pricing_rate, amount: 10)
        line_item.applied_pricing_rates.create!(pricing_rate: pricing_rate, amount: 5)

        line_item.applied_pricing_models.create!(pricing_model: pricing_model, amount: -3)
        line_item.applied_pricing_models.create!(pricing_model: pricing_model, amount: -4)
      end

      it 'recalcaulate total base on applied rate and model' do
        expect {
          subject.persist_totals
          line_item.reload
        }.to change { line_item.pricing_rates_amount }.from(nil).to(15)
         .and change { line_item.pricing_models_amount }.from(nil).to(-7)
         .and change { line_item.pricing_subtotal }.from(nil).to(15 - 7)
      end
    end
  end

  describe '#delete_previous_pricings' do
    let(:pricing_rate) { build(:cm_pricing_rate) }
    let(:pricing_model) { build(:cm_pricing_model, flat_adjustment: 10) }

    let(:pricing_rates) { [pricing_rate] }
    let(:pricing_models) { [pricing_model] }

    it 'delete previous pricings' do
      line_item.applied_pricing_rates.create!(pricing_rate: pricing_rate, amount: 10)
      line_item.applied_pricing_models.create!(pricing_model: pricing_model, amount: 10)

      expect {
        subject.delete_previous_pricings
      }.to change { line_item.applied_pricing_rates.count }.from(1).to(0)
       .and change { line_item.applied_pricing_models.count }.from(1).to(0)
    end
  end
end
