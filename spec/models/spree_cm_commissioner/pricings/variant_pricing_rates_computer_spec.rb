require "spec_helper"

RSpec.describe SpreeCmCommissioner::Pricings::VariantPricingRatesComputer do
  let!(:variant) { create(:variant, price: 10, pricing_rates: [rate_13, rate_20]) }

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
  let(:rate_13) { build(:cm_pricing_rate, price: 13) }
  let(:rate_20) { build(:cm_pricing_rate, price: 20) }

  describe '#call' do
    context 'caculate rate for specific number of quantity' do
      context 'when user purchase 5 quantity' do
        let(:purchase_quantity) { 5 }

        context 'variant has eligible model for 3-quantity' do
          before do
            allow(subject).to receive(:eligible_rate_for).with(quantity: 5).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 4).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 3).and_return(rate_20)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 2).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 1).and_return(nil)
          end

          # loop through quantity from 5 to 1 until it find eligible rate for 3 quantity
          it 'return rate for 3 quantity & return normal rate for remaining 2 quantity' do
            result = subject.call

            expect(result.size).to eq 2

            expect(result[0].pricing_rate).to eq rate_20
            expect(result[0].amount).to eq 20
            expect(result[0].quantity).to eq 3

            expect(result[1].pricing_rate).to eq nil
            expect(result[1].amount).to eq variant.price * 2
            expect(result[1].quantity).to eq 2
          end
        end

        context 'variant has eligible rate for 2-quantity' do
          before do
            allow(subject).to receive(:eligible_rate_for).with(quantity: 5).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 4).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 3).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 2).and_return(rate_13)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 1).and_return(nil)
          end

          # loop through quantity until it find eligible rate for 2-quantity
          # then check if rate can apply multiple time
          it 'return rate for for 2 quantity & applied 2 times' do
            result = subject.call

            expect(result.size).to eq 2

            # applied 2 time
            expect(result[0].pricing_rate).to eq rate_13
            expect(result[0].amount).to eq 13 * 2
            expect(result[0].quantity).to eq 4

            # normal rate for remaining quantity
            expect(result[1].pricing_rate).to eq nil
            expect(result[1].amount).to eq variant.price
            expect(result[1].quantity).to eq 1
          end
        end

        context 'variant has eligible rate for 3-quantity & 2-quantity' do
          before do
            allow(subject).to receive(:eligible_rate_for).with(quantity: 5).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 4).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 3).and_return(rate_20)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 2).and_return(rate_13)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 1).and_return(nil)
          end

          it 'return rate for 3 & 2 quantity' do
            result = subject.call

            expect(result.size).to eq 2

            expect(result[0].amount).to eq 20
            expect(result[0].quantity).to eq 3

            expect(result[1].amount).to eq 13
            expect(result[1].quantity).to eq 2
          end
        end

        context 'when it has no eligible model' do
          before do
            allow(subject).to receive(:eligible_rate_for).with(quantity: 5).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 4).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 3).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 2).and_return(nil)
            allow(subject).to receive(:eligible_rate_for).with(quantity: 1).and_return(nil)
          end

          it 'return normal rate' do
            result = subject.call

            expect(result.size).to eq 1
            expect(result[0].amount).to eq variant.price * 5
            expect(result[0].quantity).to eq 5
          end
        end
      end
    end
  end

  describe '#eligible_rate_for' do
    let!(:variant) { create(:variant, price: 10, pricing_rates: [rate_13, rate_20]) }

    it 'return 1st rate when all rates are eligble' do
      allow(rate_13).to receive(:eligible?).with(any_args).and_return(true)
      allow(rate_20).to receive(:eligible?).with(any_args).and_return(true)

      rate = subject.eligible_rate_for(quantity: 1)

      expect(rate).to eq rate_13
    end

    it 'return 2nd rate when 1st rate is not eligble' do
      allow(rate_13).to receive(:eligible?).with(any_args).and_return(false)
      allow(rate_20).to receive(:eligible?).with(any_args).and_return(true)

      rate = subject.eligible_rate_for(quantity: 1)

      expect(rate).to eq rate_20
    end

    it 'return 1st rate when 1st rate is eligble' do
      allow(rate_13).to receive(:eligible?).with(any_args).and_return(true)
      allow(rate_20).to receive(:eligible?).with(any_args).and_return(false)

      rate = subject.eligible_rate_for(quantity: 1)

      expect(rate).to eq rate_13
    end

    it 'return blank when no eligble rate' do
      allow(rate_13).to receive(:eligible?).with(any_args).and_return(false)
      allow(rate_20).to receive(:eligible?).with(any_args).and_return(false)

      rate = subject.eligible_rate_for(quantity: 1)

      expect(rate).to eq nil
    end
  end
end
