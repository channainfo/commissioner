require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VariantOptions do
  let(:option_values) { [option_value] }
  let(:variant) { create(:variant, option_values: option_values) }

  subject { described_class.new(variant) }

  describe "#location" do
    context 'when variant has location option value' do
      let(:state) { create(:state, name: 'Phnom Penh') }
      let(:option_type) { create(:cm_option_type, :location) }
      let(:option_value) { create(:cm_option_value, name: state.id, option_type: option_type) }

      it 'return state id in integer' do
        expect(subject.location).to eq state.id
      end
    end
  end

  describe "#start_date" do
    context 'when variant has start_date option value' do
      let(:option_type) { create(:cm_option_type, :start_date) }
      let(:option_value) { create(:cm_option_value, name: '2024-05-31', option_type: option_type) }

      it 'return start date in string' do
        expect(subject.start_date).to eq Time.zone.parse('2024-05-31')
      end
    end
  end

  describe "#end_date" do
    context 'when variant has end_date option value' do
      let(:option_type) { create(:cm_option_type, :end_date) }
      let(:option_value) { create(:cm_option_value, name: '2024-05-31', option_type: option_type) }

      it 'return end date in string' do
        expect(subject.end_date).to eq Time.zone.parse('2024-05-31')
      end
    end
  end

  describe "#start_time" do
    context 'when variant has start_time option value' do
      let(:option_type) { create(:cm_option_type, :start_time) }
      let(:option_value) { create(:cm_option_value, name: '12:53:00', option_type: option_type) }

      it 'return time in string' do
        expect(subject.start_time).to eq Time.zone.parse('12:53:00')
      end
    end
  end

  describe "#reminder_in_hours" do
    context 'when variant has reminder_in_hours option value' do
      let(:option_type) { create(:cm_option_type, :reminder_in_hours) }
      let(:option_value) { create(:cm_option_value, name: '4', option_type: option_type) }

      it 'return reminder in hours in integer' do
        expect(subject.reminder_in_hours).to eq 4
      end
    end
  end

  describe "#duration_in_hours" do
    context 'when variant has duration_in_hours option value' do
      let(:option_type) { create(:cm_option_type, :duration_in_hours) }
      let(:option_value) { create(:cm_option_value, name: '2', option_type: option_type) }

      it 'return duration in integer' do
        expect(subject.duration_in_hours).to eq 2
      end
    end
  end

  describe "#duration_in_minutes" do
    context 'when variant has duration_in_minutes option value' do
      let(:option_type) { create(:cm_option_type, :duration_in_minutes) }
      let(:option_value) { create(:cm_option_value, name: '20', option_type: option_type) }

      it 'return duration in integer' do
        expect(subject.duration_in_minutes).to eq 20
      end
    end
  end

  describe "#duration_in_seconds" do
    context 'when variant has duration_in_seconds option value' do
      let(:option_type) { create(:cm_option_type, :duration_in_seconds) }
      let(:option_value) { create(:cm_option_value, name: '3200', option_type: option_type) }

      it 'return duration in integer' do
        expect(subject.duration_in_seconds).to eq 3200
      end
    end
  end

  describe "#payment_option" do
    context 'when variant has payment_option option value' do
      let(:option_type) { create(:cm_option_type, :payment_option) }
      let(:option_value) { create(:cm_option_value, name: 'post-paid', option_type: option_type) }

      it 'return payment_option in string' do
        expect(subject.payment_option).to eq 'post-paid'
      end
    end
  end

  describe "#delivery_option" do
    context 'when variant has delivery_option option value' do
      let(:option_type) { create(:cm_option_type, :delivery_option) }

      let(:option_value1) { create(:cm_option_value, name: 'delivery', option_type: option_type) }
      let(:option_value2) { create(:cm_option_value, name: 'pickup', option_type: option_type) }

      it 'return delivery_option in string' do
        variant1 = create(:variant, option_values: [option_value1])
        variant2 = create(:variant, option_values: [option_value2])

        subject1 = described_class.new(variant1)
        subject2 = described_class.new(variant2)

        expect(subject1.delivery_option).to eq 'delivery'
        expect(subject2.delivery_option).to eq 'pickup'
      end
    end

    context 'when variant has no delivery_option option value' do
      let(:option_values) { [ create(:option_value, name: 'just-to-pass-variant-validation') ] }

      it 'return nil' do
        expect(subject.delivery_option).to eq nil
      end
    end
  end

  describe "#max_quantity_per_order" do
    context 'when variant has max_quantity_per_order option value' do
      let(:option_type) { create(:cm_option_type, :max_quantity_per_order) }
      let(:option_value) { create(:cm_option_value, name: '1', option_type: option_type) }

      it 'return in integer' do
        expect(subject.max_quantity_per_order).to eq 1
      end
    end
  end

  describe "#due_date" do
    context 'when variant has due_date option value' do
      let(:option_type) { create(:cm_option_type, :due_date) }
      let(:option_value) { create(:cm_option_value, name: '10', option_type: option_type) }

      it 'return due_date in days integer' do
        expect(subject.due_date).to eq 10
      end
    end
  end

  describe "#month" do
    context 'when variant has month option value' do
      let(:option_type) { create(:cm_option_type, :month) }
      let(:option_value) { create(:cm_option_value, name: '10', option_type: option_type) }

      it 'return month in integer' do
        expect(subject.month).to eq 10
      end
    end
  end

  describe "#number_of_adults" do
    context 'when variant has number_of_adults option value' do
      let(:option_type) { create(:cm_option_type, :number_of_adults) }
      let(:option_value) { create(:cm_option_value, name: '10', option_type: option_type) }

      it 'return number_of_adults in integer' do
        expect(subject.number_of_adults).to eq 10
      end
    end

    context 'when variant has no option value' do
      let(:option_values) { [ create(:option_value) ] }

      it 'return DEFAULT_NUMBER_OF_ADULTS by default' do
        expect(subject.number_of_adults).to eq described_class::DEFAULT_NUMBER_OF_ADULTS
      end
    end
  end

  describe "#number_of_kids" do
    context 'when variant has number_of_kids option value' do
      let(:option_type) { create(:cm_option_type, :number_of_kids) }
      let(:option_value) { create(:cm_option_value, name: '10', option_type: option_type) }

      it 'return number_of_kids in integer' do
        expect(subject.number_of_kids).to eq 10
      end
    end

    context 'when variant has no option value' do
      let(:option_values) { [ create(:option_value) ] }

      it 'return 0 by default' do
        expect(subject.number_of_kids).to eq 0
      end
    end
  end

  describe "#number_of_guests" do
    let(:option_type1) { create(:cm_option_type, :number_of_adults) }
    let(:option_type2) { create(:cm_option_type, :number_of_kids) }

    let(:option_value1) { create(:cm_option_value, name: '2', option_type: option_type1) }
    let(:option_value2) { create(:cm_option_value, name: '3', option_type: option_type2) }

    let(:option_values) { [option_value1, option_value2] }

    it 'return sum of kids + adults' do
      expect(subject.number_of_guests).to eq 2 + 3
    end
  end

  describe "#kids_age_max" do
    context 'when variant has kids_age_max option value' do
      let(:option_type) { create(:cm_option_type, :kids_age_max) }
      let(:option_value) { create(:cm_option_value, name: '10', option_type: option_type) }

      it 'return kids_age_max in integer' do
        expect(subject.kids_age_max).to eq 10
      end
    end

    context 'when variant has no kids_age_max option value' do
      let(:option_values) { [ create(:option_value, name: 'just-to-skip-variant-validation') ] }

      it 'return default age max' do
        expect(subject.kids_age_max).to eq described_class::DEFAULT_KIDS_AGE_MAX
      end
    end
  end

  describe "#allowed_extra_adults" do
    context 'when variant has allowed_extra_adults option value' do
      let(:option_type) { create(:cm_option_type, :allowed_extra_adults) }
      let(:option_value) { create(:cm_option_value, name: '10', option_type: option_type) }

      it 'return allowed_extra_adults in integer' do
        expect(subject.allowed_extra_adults).to eq 10
      end
    end
  end

  describe "#allowed_extra_kids" do
    context 'when variant has allowed_extra_kids option value' do
      let(:option_type) { create(:cm_option_type, :allowed_extra_kids) }
      let(:option_value) { create(:cm_option_value, name: '10', option_type: option_type) }

      it 'return allowed_extra_kids in integer' do
        expect(subject.allowed_extra_kids).to eq 10
      end
    end

    context 'when variant has no allowed_extra_kids option value' do
      let(:option_values) { [ create(:option_value) ] }

      it 'return 0 by default' do
        expect(subject.allowed_extra_kids).to eq 0
      end
    end
  end

  describe "#bib_prefix" do
    context "when variant has bib-prefix option value" do
      let(:option_type) { create(:cm_option_type, :bib_prefix) }
      let(:option_value) { create(:cm_option_value, name: 'running-ticket', option_type: option_type) }

      it 'return bib_prefix in string' do
        expect(subject.bib_prefix).to eq 'running-ticket'
      end
    end

    context "when variant has no bib-prefix option value" do
      let(:option_values) { [ create(:option_value) ] }

      it 'return nil' do
        expect(subject.bib_prefix).to eq nil
      end
    end
  end
end
