require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Pricings::LineItemPricingsCalculator do
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

    context 'USECASES' do
      context 'when product is accomodation' do
        let(:date1) { Date.current }
        let(:date2) { Date.current + 1.days }
        let(:date3) { Date.current + 2.days }
        let(:date4) { Date.current + 3.days }

        context 'variant has eligible rate & model' do
          context 'has custom-date rate & extra-adults model' do
            let(:date_rule) { build(:cm_custom_date_pricing_rule, dates: [date1, date2]) }
            let(:extra_adults_rule) { build(:cm_extra_adults_pricing_rule, extra_adults: 2) }

            let(:pricing_rate) { build(:cm_pricing_rate, pricing_rules: [date_rule], price: 50) }
            let(:pricing_model) { build(:cm_pricing_model, pricing_rules: [extra_adults_rule], percent_adjustment: 10) }

            let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :adults), create(:cm_option_type, :allowed_extra_adults)]) }
            let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [pricing_rate], pricing_models: [pricing_model], option_values: [adults(4), allowed_extra_adults(2)]) }

            let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: date1, to_date: date4, public_metadata: { number_of_adults: 6 }) }

            let!(:previous_rate) { line_item.applied_pricing_rates.create!(pricing_rate: pricing_rate, amount: 10) }
            let!(:previous_model) { line_item.applied_pricing_models.create!(pricing_model: pricing_model, amount: 4) }

            before { subject.call }

            it 'update rate to new rate amount on night 1,2 & default rate on night 3' do
              expect(line_item.date_range.size).to eq 3
              expect(line_item.pricing_rates_amount).to eq 50 + 50 + 40
            end

            it 'update adjustment 10% adjustment for extra 2 adults for all 3-nights' do
              expect(line_item.pricing_models_amount).to eq (50 + 50 + 40) * 0.1
            end

            it 'update new subtotal combined of applied rate + applied model' do
              expect(line_item.pricing_subtotal).to eq (50 + 50 + 40) + (50 + 50 + 40) * 0.1
            end

            it 'deleted previous pricings' do
              expect { previous_rate.reload }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find SpreeCmCommissioner::AppliedPricingRate with 'id'=#{previous_rate.id}")
              expect { previous_model.reload }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find SpreeCmCommissioner::AppliedPricingModel with 'id'=#{previous_model.id}")
            end
          end

          context 'has weekdays rate & extra-kids model' do
            let(:weekday_rule) { build(:cm_weekdays_pricing_rule, weekdays: [date1.wday, date2.wday]) }
            let(:extra_kids_rule) { build(:cm_extra_kids_pricing_rule, extra_kids: 2) }

            let(:pricing_rate) { build(:cm_pricing_rate, pricing_rules: [weekday_rule], price: 50) }
            let(:pricing_model) { build(:cm_pricing_model, pricing_rules: [extra_kids_rule], percent_adjustment: 10) }

            let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :kids), create(:cm_option_type, :allowed_extra_kids)]) }
            let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [pricing_rate], pricing_models: [pricing_model], option_values: [kids(3), allowed_extra_kids(2)]) }

            let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: date1, to_date: date4, public_metadata: { number_of_kids: 5 }) }

            before { subject.call }

            it 'update rate to new rate amount on night 1,2 & default rate on night 3' do
              expect(line_item.pricing_rates_amount).to eq 50+50+40
            end

            it 'update adjustment to 10% adjustment for extra 2 kids for all 3-nights' do
              expect(line_item.pricing_models_amount).to eq (50+50+40) * 0.1
            end

            it 'update new subtotal combined of applied rate + applied model' do
              expect(line_item.pricing_subtotal).to eq (50+50+40) + (50+50+40) * 0.1
            end
          end

          context 'has weekdays rate & group booking model' do
            let(:weekday_rule) { build(:cm_weekdays_pricing_rule, weekdays: [date1.wday, date2.wday]) }

            let(:quantity_3_rule) { build(:cm_group_pricing_rule, quantity: 3) }
            let(:quantity_4_rule) { build(:cm_group_pricing_rule, quantity: 4) }

            let(:pricing_rate) { build(:cm_pricing_rate, pricing_rules: [weekday_rule], price: 50) }
            let(:pricing_model1) { build(:cm_pricing_model, pricing_rules: [quantity_3_rule], percent_adjustment: 10) }
            let(:pricing_model2) { build(:cm_pricing_model, pricing_rules: [quantity_4_rule], percent_adjustment: 15) }

            let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :kids), create(:cm_option_type, :allowed_extra_kids)]) }
            let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [pricing_rate], pricing_models: [pricing_model1, pricing_model2], option_values: [kids(3), allowed_extra_kids(2)]) }

            let(:line_item) { create(:line_item, variant: variant, quantity: 8, from_date: date1, to_date: date4) }

            before { subject.call }

            it 'update rate to new rate amount on night 1,2 & default rate on night 3 for all 8 rooms' do
              expect(line_item.pricing_rates_amount).to eq (50+50+40) * 8
            end

            it 'update adjustment to 10% adjustment for 3 room & 15% adjustment for 4 room' do
              first_3_rooms = (50+50+40) * 0.10 * 3
              last_4_rooms = (50+50+40) * 0.15 * 4

              expect(line_item.pricing_models_amount).to eq first_3_rooms + last_4_rooms
            end

            it 'update new subtotal combined of applied rate + applied model' do
              rate_amount = (50+50+40) * 8
              model_amount = (50+50+40) * 0.10 * 3 + (50+50+40) * 0.15 * 4

              expect(line_item.pricing_subtotal).to eq rate_amount + model_amount
            end
          end
        end

        context 'when variant may have an eligible rate, model, or neither' do
          context 'has NO eligible rate but has eligible model' do
            let(:weekday_rule) { build(:cm_weekdays_pricing_rule, weekdays: []) }
            let(:extra_kids_rule) { build(:cm_extra_kids_pricing_rule, extra_kids: 2) }

            let(:ineligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [weekday_rule], price: 50) }
            let(:eligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [extra_kids_rule], percent_adjustment: 10) }

            let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :kids), create(:cm_option_type, :allowed_extra_kids)]) }
            let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [ineligible_pricing_rate], pricing_models: [eligible_pricing_model], option_values: [kids(3), allowed_extra_kids(2)]) }

            let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: date1, to_date: date4, public_metadata: { number_of_kids: 5 }) }

            before { subject.call }

            it 'update pricing_rates_amount to normal rate for 3 nights' do
              expect(line_item.pricing_rates_amount).to eq 40+40+40
            end

            it 'update adjustment to 10% adjustment for extra 2 kids for all 3-nights' do
              expect(line_item.pricing_models_amount).to eq (40+40+40) * 0.1
            end

            it 'update new subtotal combined of applied rate + applied model' do
              expect(line_item.pricing_subtotal).to eq (40+40+40) + (40+40+40) * 0.1
            end
          end

          context 'has eligible weekday rate but NO eligible model' do
            let(:weekday_rule) { build(:cm_weekdays_pricing_rule, weekdays: [date1.wday, date2.wday]) }
            let(:extra_kids_rule) { build(:cm_extra_kids_pricing_rule, extra_kids: 3) }

            let(:eligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [weekday_rule], price: 50) }
            let(:ineligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [extra_kids_rule], percent_adjustment: 10) }

            let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :kids), create(:cm_option_type, :allowed_extra_kids)]) }
            let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [eligible_pricing_rate], pricing_models: [ineligible_pricing_model], option_values: [kids(3), allowed_extra_kids(2)]) }

            let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: date1, to_date: date4, public_metadata: { number_of_kids: 5 }) }

            before { subject.call }

            it 'update rate to new rate amount on night 1,2 & default rate on night 3' do
              expect(line_item.pricing_rates_amount).to eq 50+50+40
            end

            it 'update pricing_models_amount to 0' do
              expect(line_item.pricing_models_amount).to eq 0
            end

            it 'update new subtotal combined of applied rate + applied model' do
              expect(line_item.pricing_subtotal).to eq 50+50+40
            end
          end

          context 'has NO eligible weekday rate & model' do
            let(:weekday_rule) { build(:cm_weekdays_pricing_rule, weekdays: []) }
            let(:extra_kids_rule) { build(:cm_extra_kids_pricing_rule, extra_kids: 3) }

            let(:eligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [weekday_rule], price: 50) }
            let(:ineligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [extra_kids_rule], percent_adjustment: 10) }

            let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :kids), create(:cm_option_type, :allowed_extra_kids)]) }
            let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [eligible_pricing_rate], pricing_models: [ineligible_pricing_model], option_values: [kids(3), allowed_extra_kids(2)]) }

            let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: date1, to_date: date4, public_metadata: { number_of_kids: 5 }) }

            before { subject.call }

            it 'update pricing_rates_amount to normal rate for all 3 nights' do
              expect(line_item.pricing_rates_amount).to eq 40+40+40
            end

            it 'update pricing_models_amount to 0' do
              expect(line_item.pricing_models_amount).to eq 0
            end

            it 'update new subtotal combined of applied rate + applied model' do
              expect(line_item.pricing_subtotal).to eq 40+40+40
            end
          end
        end
      end

      context 'when product is ecommerce' do
        context 'variant has eligible rate & model' do
          context 'has early bird rate & group booking model' do
            let(:early_bird_rule) { build(:cm_early_bird_pricing_rule, from: Date.current, to: Date.current + 2.days) }

            let(:quantity_3_rule) { build(:cm_group_pricing_rule, quantity: 3) }
            let(:quantity_4_rule) { build(:cm_group_pricing_rule, quantity: 4) }

            let(:pricing_rate) { build(:cm_pricing_rate, pricing_rules: [early_bird_rule], price: 50) }
            let(:pricing_model1) { build(:cm_pricing_model, pricing_rules: [quantity_3_rule], percent_adjustment: 10) }
            let(:pricing_model2) { build(:cm_pricing_model, pricing_rules: [quantity_4_rule], percent_adjustment: 15) }

            let(:product) { create(:product) }
            let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [pricing_rate], pricing_models: [pricing_model1, pricing_model2]) }

            let(:line_item) { create(:line_item, variant: variant, quantity: 8, created_at: Date.current) }

            before { subject.call }

            it 'update to new early bird rate for all 8 quantity' do
              expect(line_item.pricing_rates_amount).to eq 50 * 8
            end

            it 'update 10% adjustment for 3 quantity & 15% adjustment for 4 quantity' do
              first_3_rooms = 50 * 0.10 * 3
              last_4_rooms = 50 * 0.15 * 4

              expect(line_item.pricing_models_amount).to eq first_3_rooms + last_4_rooms
            end

            it 'update new subtotal combined of applied rate + applied model' do
              rate_amount = 50 * 8
              model_amount = 50 * 0.10 * 3 + 50 * 0.15 * 4

              expect(line_item.pricing_subtotal).to eq rate_amount + model_amount
            end
          end
        end

        context 'when variant may have an eligible rate, model, or neither' do
          context 'has NO eligible rate but has eligible model' do
            let(:early_bird_rule) { build(:cm_early_bird_pricing_rule, from: Date.current + 7.days, to: Date.current + 10.days) }
            let(:quantity_rule) { build(:cm_group_pricing_rule, quantity: 3) }

            let(:ineligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [early_bird_rule], price: 50) }
            let(:eligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [quantity_rule], percent_adjustment: 10) }

            let(:product) { create(:product) }
            let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [ineligible_pricing_rate], pricing_models: [eligible_pricing_model]) }
            let(:line_item) { create(:line_item, variant: variant, quantity: 3, created_at: Date.current) }

            before { subject.call }

            it 'update pricing_rates_amount to normal rate for all 3 quantity' do
              expect(line_item.pricing_rates_amount).to eq 40 * 3
            end

            it 'update 10% adjustment for all 3 quantity' do
              expect(line_item.pricing_models_amount).to eq (40 * 3) * 0.1
            end

            it 'update new subtotal combined of applied rate + applied model' do
              expect(line_item.pricing_subtotal).to eq (40 * 3) + (40 * 3) * 0.1
            end
          end

          context 'has eligible rate & NO eligible model' do
            let(:early_bird_rule) { build(:cm_early_bird_pricing_rule, from: Date.current, to: Date.current + 3.days) }
            let(:quantity_rule) { build(:cm_group_pricing_rule, quantity: 4) }

            let(:eligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [early_bird_rule], price: 50) }
            let(:ineligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [quantity_rule], percent_adjustment: 10) }

            let(:product) { create(:product) }
            let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [eligible_pricing_rate], pricing_models: [ineligible_pricing_model]) }
            let(:line_item) { create(:line_item, variant: variant, quantity: 3, created_at: Date.current) }

            before { subject.call }

            it 'update to new early bird rate for all 3 quantity' do
              expect(line_item.pricing_rates_amount).to eq 50 * 3
            end

            it 'update pricing_models_amount to 0' do
              expect(line_item.pricing_models_amount).to eq 0
            end

            it 'update new subtotal combined of applied rate + applied model' do
              expect(line_item.pricing_subtotal).to eq(50 * 3)
            end
          end

          context 'has NO eligible rate & model' do
            let(:early_bird_rule) { build(:cm_early_bird_pricing_rule, from: Date.current + 7.days, to: Date.current + 10.days) }
            let(:quantity_rule) { build(:cm_group_pricing_rule, quantity: 4) }

            let(:ineligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [early_bird_rule], price: 50) }
            let(:ineligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [quantity_rule], percent_adjustment: 10) }

            let(:product) { create(:product) }
            let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [ineligible_pricing_rate], pricing_models: [ineligible_pricing_model]) }
            let(:line_item) { create(:line_item, variant: variant, quantity: 3, created_at: Date.current) }

            before { subject.call }

            it 'update pricing_rates_amount to normal rate for all 3 quantity' do
              expect(line_item.pricing_rates_amount).to eq 40 * 3
            end

            it 'update pricing_models_amount to 0' do
              expect(line_item.pricing_models_amount).to eq 0
            end

            it 'update new subtotal combined of applied rate + applied model' do
              expect(line_item.pricing_subtotal).to eq 40 * 3 + 0
            end
          end
        end
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

  def date_options_klass = SpreeCmCommissioner::Pricings::DateOptions

  def kids(number)
    kids_option_type = create(:cm_option_type, :kids)
    create(:option_value, name: "#{number}-kids", presentation: "#{number}", option_type: kids_option_type)
  end

  def adults(number)
    adults_option_type = create(:cm_option_type, :adults)
    create(:option_value, name: "#{number}-adults", presentation: "#{number}", option_type: adults_option_type)
  end

  def allowed_extra_kids(number)
    allowed_extra_kids_option_type = create(:cm_option_type, :allowed_extra_kids)
    create(:option_value, name: "allowed-#{number}-kids", presentation: "#{number}", option_type: allowed_extra_kids_option_type)
  end

  def allowed_extra_adults(number)
    allowed_extra_adults_option_type = create(:cm_option_type, :allowed_extra_adults)
    create(:option_value, name: "allowed-#{number}-adults", presentation: "#{number}", option_type: allowed_extra_adults_option_type)
  end
end