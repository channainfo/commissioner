require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AccommodationPriceRuleCalculator do
  let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
  let!(:phnom_penh_hotel) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', state_id: phnom_penh.id, min_price: 20, max_price: 50) }

  context '.call' do
    context "when no rules" do
      let(:pp_rules) { described_class.call(vendor: phnom_penh_hotel, from_date: date('2022-12-29'), to_date: date('2022-12-30')) }

      it 'return 0 pricing rules' do
        expect(pp_rules.value).to eq([])
      end
    end

    context "when rules expired" do
      let!(:new_year_rule) { create(:cm_vendor_pricing_rule, date_rule: { type: 'fixed_date', name: 'Happy New Year', value: '2023-01-01' }, length: 3, position: 1, active: false, vendor: phnom_penh_hotel) }
      let(:pp_rules) { described_class.call(vendor: phnom_penh_hotel, from_date: date('2022-12-31'), to_date: date('2022-12-02')) }

      it 'return 0 pricing rules' do
        expect(pp_rules.value).to eq([])
      end
    end

    context "when has rules" do
      let!(:national_culture_rule) { create(:cm_vendor_pricing_rule, date_rule: { type: 'fixed_date', name: 'National Culture Day', value: '2023-03-03' }, length: 1, position: 1, operator: '-', amount: 5, vendor: phnom_penh_hotel) }
      let!(:women_day_rule)    { create(:cm_vendor_pricing_rule, date_rule: { type: 'fixed_date', name: 'Women Day', value: '2023-03-08' }, length: 3, position: 2, operator: '+', amount: 10, vendor: phnom_penh_hotel) }
      let!(:water_policy_rule) { create(:cm_vendor_pricing_rule, date_rule: { type: 'fixed_date', name: 'Water Policy Day', value: '2023-03-04' }, length: 2, position: 3, operator: '-', amount: 10, vendor: phnom_penh_hotel) }

      it 'return price by dates collection for women_day_rule only' do
        price_rules = described_class.call(vendor: phnom_penh_hotel, from_date: date('2023-03-08'), to_date: date('2023-03-09')).value

        national_culture_rule_result = price_rules.find { |rule| rule.id == national_culture_rule.id }
        women_day_rule_result = price_rules.find { |rule| rule.id == women_day_rule.id }
        water_policy_rule_result = price_rules.find { |rule| rule.id == water_policy_rule.id }

        expect(price_rules.length).to eq 3
        expect(national_culture_rule_result.price_by_dates.length).to eq 0

        expect(water_policy_rule_result.price_by_dates.length).to eq 0
        expect(water_policy_rule_result.min_price_by_rule).to be_nil
        expect(water_policy_rule_result.max_price_by_rule).to be_nil

        expect(women_day_rule_result.price_by_dates.length).to eq 2
        expect(women_day_rule_result.min_price_by_rule).to eq 30
        expect(women_day_rule_result.max_price_by_rule).to eq 60
      end

      it 'return price by dates collection for national_culture_rule and water_policy_rule only' do
        price_rules = described_class.call(vendor: phnom_penh_hotel, from_date: date('2023-03-03'), to_date: date('2023-03-05')).value

        national_culture_rule_result = price_rules.find { |rule| rule.id == national_culture_rule.id }
        women_day_rule_result = price_rules.find { |rule| rule.id == women_day_rule.id }
        water_policy_rule_result = price_rules.find { |rule| rule.id == water_policy_rule.id }

        expect(price_rules.length).to eq 3
        expect(women_day_rule_result.price_by_dates.length).to eq 0

        expect(national_culture_rule_result.price_by_dates.length).to eq 1
        expect(national_culture_rule_result.min_price_by_rule).to eq 15
        expect(national_culture_rule_result.max_price_by_rule).to eq 45

        expect(water_policy_rule_result.price_by_dates.length).to eq 2
        expect(water_policy_rule_result.min_price_by_rule).to eq 10
        expect(water_policy_rule_result.max_price_by_rule).to eq 40
      end

      it 'return price by dates collection for all price rules' do
        price_rules = described_class.call(vendor: phnom_penh_hotel, from_date: date('2023-03-01'), to_date: date('2023-03-10')).value

        national_culture_rule_result = price_rules.find { |rule| rule.id == national_culture_rule.id }
        women_day_rule_result = price_rules.find { |rule| rule.id == women_day_rule.id }
        water_policy_rule_result = price_rules.find { |rule| rule.id == water_policy_rule.id }

        expect(price_rules.length).to eq 3

        expect(national_culture_rule_result.price_by_dates.length).to eq 1
        expect(national_culture_rule_result.min_price_by_rule).to eq 15
        expect(national_culture_rule_result.max_price_by_rule).to eq 45

        expect(women_day_rule_result.price_by_dates.length).to eq 3
        expect(women_day_rule_result.min_price_by_rule).to eq 30
        expect(women_day_rule_result.max_price_by_rule).to eq 60

        expect(water_policy_rule_result.price_by_dates.length).to eq 2
        expect(water_policy_rule_result.min_price_by_rule).to eq 10
        expect(water_policy_rule_result.max_price_by_rule).to eq 40
      end
    end
  end
end
