require "spec_helper"

RSpec.describe SpreeCmCommissioner::Pricings::VariantPricingModelsComputer do
  let!(:variant) { create(:variant, price: 10) }

  let(:booking_date) { Date.current }
  let(:purchase_quantity) { 5 }
  let(:guest_options) { {} }
  let(:date_unit_options) { {} }

  subject do
    described_class.new(
      variant: variant,
      booking_date: booking_date,
      quantity: purchase_quantity,
      guest_options: guest_options,
      date_unit_options: date_unit_options
    )
  end

  # models
  let(:flat_adjustment_13) { build(:cm_pricing_model, flat_adjustment: -13) }
  let(:flat_adjustment_20) { build(:cm_pricing_model, flat_adjustment: -20) }

  let(:percent_adjustment_17) { build(:cm_pricing_model, percent_adjustment: -17) }
  let(:percent_adjustment_23) { build(:cm_pricing_model, percent_adjustment: -23) }

  describe '#call' do
    context 'caculate adjustment for specific number of quantity' do
      context 'when user purchase 5 quantity' do
        context 'variant has eligible model for 3-quantity' do
          before do
            allow(subject).to receive(:eligible_model_for).with(quantity: 5).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 4).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 3).and_return(flat_adjustment_20)
            allow(subject).to receive(:eligible_model_for).with(quantity: 2).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 1).and_return(nil)
          end

          # loop through quantity from 5 to 1 until it find eligible model
          it 'return adjustment of 3 quantity' do
            result = subject.call

            expect(result.size).to eq 1
            expect(result[0].amount).to eq -20
          end
        end

        context 'variant has eligible model for 2-quantity' do
          before do
            allow(subject).to receive(:eligible_model_for).with(quantity: 5).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 4).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 3).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 2).and_return(flat_adjustment_13)
            allow(subject).to receive(:eligible_model_for).with(quantity: 1).and_return(nil)
          end

          # loop through quantity until it find eligible model
          # then check if model can apply multiple time
          it 'return adjustment for 2 quantity then applied 2 times' do
            result = subject.call

            # applied 2 time
            expect(result.size).to eq 1
            expect(result[0].pricing_model).to eq flat_adjustment_13
            expect(result[0].amount).to eq -13 * 2
            expect(result[0].quantity).to eq 2 * 2
          end
        end

        context 'variant has eligible model for 3-quantity & 2-quantity' do
          before do
            allow(subject).to receive(:eligible_model_for).with(quantity: 5).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 4).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 3).and_return(flat_adjustment_20)
            allow(subject).to receive(:eligible_model_for).with(quantity: 2).and_return(flat_adjustment_13)
            allow(subject).to receive(:eligible_model_for).with(quantity: 1).and_return(nil)
          end

          # loop through quantity until it find eligible model
          # then keep looping to find eligible model for remaining quantity.
          it 'return adjustments for 3-quantity & 2-quantity' do
            result = subject.call

            expect(result.size).to eq 2

            expect(result[0].pricing_model).to eq flat_adjustment_20
            expect(result[0].amount).to eq -20
            expect(result[0].quantity).to eq 3

            expect(result[1].pricing_model).to eq flat_adjustment_13
            expect(result[1].amount).to eq -13
            expect(result[1].quantity).to eq 2
          end
        end

        context 'when it has no eligible model' do
          before do
            allow(subject).to receive(:eligible_model_for).with(quantity: 5).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 4).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 3).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 2).and_return(nil)
            allow(subject).to receive(:eligible_model_for).with(quantity: 1).and_return(nil)
          end

          it 'return 0 adjustment' do
            result = subject.call

            expect(result.size).to eq 0
          end
        end
      end
    end
  end

  describe '#eligible_model_for' do
    let!(:variant) { create(:variant, price: 10, pricing_models: [flat_adjustment_13, flat_adjustment_20]) }

    it 'return 1st model when all models are eligble' do
      allow(flat_adjustment_13).to receive(:eligible?).with(any_args).and_return(true)
      allow(flat_adjustment_20).to receive(:eligible?).with(any_args).and_return(true)

      model = subject.eligible_model_for(quantity: 1)

      expect(model).to eq flat_adjustment_13
    end

    it 'return 2nd model when only 1st model is not eligble' do
      allow(flat_adjustment_13).to receive(:eligible?).with(any_args).and_return(false)
      allow(flat_adjustment_20).to receive(:eligible?).with(any_args).and_return(true)

      model = subject.eligible_model_for(quantity: 1)

      expect(model).to eq flat_adjustment_20
    end

    it 'return 1st model when only 1st model it is eligble' do
      allow(flat_adjustment_13).to receive(:eligible?).with(any_args).and_return(true)
      allow(flat_adjustment_20).to receive(:eligible?).with(any_args).and_return(false)

      model = subject.eligible_model_for(quantity: 1)

      expect(model).to eq flat_adjustment_13
    end

    it 'return blank when no eligble model' do
      allow(flat_adjustment_13).to receive(:eligible?).with(any_args).and_return(false)
      allow(flat_adjustment_20).to receive(:eligible?).with(any_args).and_return(false)

      model = subject.eligible_model_for(quantity: 1)

      expect(model).to eq nil
    end
  end

  describe '#caculate_adjustment_for' do
    it 'caculate adjustment base on rate price' do
      allow(subject).to receive(:rate_options_for).with(quantity: 2).and_return({ amount: 50, currency: variant.currency })

      result = subject.calculate_adjustment_for(model: percent_adjustment_17, quantity: 2)

      expect(result).to eq -0.17 * 50
    end
  end
end
