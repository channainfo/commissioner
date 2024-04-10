require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingRules::EarlyBird, type: :model do
  let(:options) { SpreeCmCommissioner::Pricings::Options.new }

  subject { create(:cm_early_bird_pricing_rule) }

  describe "validations" do
    it 'is valid with valid booking dates' do
      subject.preferred_booking_date_from = '2024-04-01'
      subject.preferred_booking_date_to = '2024-04-20'
      subject.validate

      expect(subject.errors).to be_empty
    end

    it 'return error when booking_date_from is blank' do
      subject.preferred_booking_date_from = nil
      subject.preferred_booking_date_to = '2024-04-20'
      subject.validate

      expect(subject.errors[:booking_date_from]).to include('invalid_booking_date_from')
    end

    it 'return error when booking_date_to is blank' do
      subject.preferred_booking_date_from = '2024-04-01'
      subject.preferred_booking_date_to = nil
      subject.validate

      expect(subject.errors[:booking_date_to]).to include('invalid_booking_date_to')
    end

    it 'return error when booking_date_to is earlier than booking_date_from' do
      subject.preferred_booking_date_from = '2024-04-20'
      subject.preferred_booking_date_to = '2024-04-01'
      subject.validate

      expect(subject.errors[:booking_date]).to include('invalid_booking_date')
    end
  end

  describe '#applicable?' do
    it 'returns true when options contain booking date' do
      options = SpreeCmCommissioner::Pricings::Options.new(booking_date: Date.current)
      expect(subject.applicable?(options)).to be true
    end

    it 'returns false when options do not contain booking date' do
      options = SpreeCmCommissioner::Pricings::Options.new(booking_date: nil)
      expect(subject.applicable?(options)).to be false
    end

    it 'returns false when options is not instance of Pricings::Options' do
      options = double(:some_randome_class)
      expect(subject.applicable?(options)).to be false
    end
  end

  describe '#eligible?' do
    subject { create(:cm_early_bird_pricing_rule, preferred_booking_date_from: Date.current, preferred_booking_date_to: Date.current + 3.days) }

    context 'when booking date is within the range' do
      it 'returns true' do
        options1 = SpreeCmCommissioner::Pricings::Options.new(booking_date: Date.current)
        options2 = SpreeCmCommissioner::Pricings::Options.new(booking_date: Date.current + 1.days)
        options3 = SpreeCmCommissioner::Pricings::Options.new(booking_date: Date.current + 2.days)
        options4 = SpreeCmCommissioner::Pricings::Options.new(booking_date: Date.current + 3.days)

        expect(subject.eligible?(options1)).to eq(true)
        expect(subject.eligible?(options2)).to eq(true)
        expect(subject.eligible?(options3)).to eq(true)
        expect(subject.eligible?(options4)).to eq(true)
      end
    end

    context 'when booking date is outside the range' do
      it 'returns false' do
        options1 = SpreeCmCommissioner::Pricings::Options.new(booking_date: Date.current - 1.days)
        options2 = SpreeCmCommissioner::Pricings::Options.new(booking_date: Date.current + 4.days)

        expect(subject.eligible?(options1)).to eq(false)
        expect(subject.eligible?(options2)).to eq(false)
      end
    end
  end
end
