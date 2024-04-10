require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingRules::ExtraAdults, type: :model do
  include GuestOptionsHelper

  subject { build(:cm_extra_adults_pricing_rule) }

  describe 'validations' do
    context 'when extra adults is not present' do
      it 'set to 0 & return invalid' do
        subject.preferred_min_extra_adults = nil
        subject.preferred_max_extra_adults = nil

        subject.validate

        expect(subject.preferred_min_extra_adults).to eq 0
        expect(subject.preferred_max_extra_adults).to eq 0

        expect(subject.errors[:preferred_min_extra_adults]).to include('must be greater than 0')
        expect(subject.errors[:preferred_max_extra_adults]).to include('must be greater than 0')
      end
    end

    context 'when extra adults is <= 0' do
      it 'invalid' do
        subject.preferred_min_extra_adults = 0
        subject.preferred_max_extra_adults = -1

        subject.validate

        expect(subject.errors[:preferred_min_extra_adults]).to include('must be greater than 0')
        expect(subject.errors[:preferred_max_extra_adults]).to include('must be greater than 0')
      end
    end

    context 'when min extra kid > max extra kid' do
      it 'invalid' do
        subject.preferred_min_extra_adults = 5
        subject.preferred_max_extra_adults = 2

        subject.validate

        expect(subject.valid?).to be false
        expect(subject.errors[:extra_adults]).to include('invalid_extra_adults')
      end
    end

    context 'when min_extra_adults & max_extra_adults > 0 & max_extra_adults > min_extra_adults' do
      it 'valid' do
        subject.preferred_min_extra_adults = 2
        subject.preferred_max_extra_adults = 5

        subject.validate

        expect(subject.valid?).to be true
      end
    end
  end

  describe '#applicable?' do
    it 'returns true when options contain extra_adults' do
      options = options_klass.new(guest_options: guest_options_klass.new(extra_adults: 1))
      expect(subject.applicable?(options)).to be true
    end

    it 'returns false when options do not contain booking date' do
      options = options_klass.new(guest_options: guest_options_klass.new(extra_adults: nil))
      expect(subject.applicable?(options)).to be false
    end

    it 'returns false when options is not instance of Pricings::GuestOptions' do
      options = double(:some_randome_class)
      expect(subject.applicable?(options)).to be false
    end
  end

  describe '#eligible?' do
    subject { build(:cm_extra_adults_pricing_rule, preferred_min_extra_adults: 1, preferred_max_extra_adults: 3) }

    it 'returns true when extra adults is within preferred range' do
      options1 = options_klass.new(guest_options: guest_options_klass.new(extra_adults: 1))
      options2 = options_klass.new(guest_options: guest_options_klass.new(extra_adults: 2))
      options3 = options_klass.new(guest_options: guest_options_klass.new(extra_adults: 3))

      expect(subject.eligible?(options1)).to be true
      expect(subject.eligible?(options2)).to be true
      expect(subject.eligible?(options3)).to be true
    end

    it 'returns false when extra adults do not fall within preferred range' do
      options1 = options_klass.new(guest_options: guest_options_klass.new(extra_adults: 0))
      options2 = options_klass.new(guest_options: guest_options_klass.new(extra_adults: 4))

      expect(subject.eligible?(options1)).to be false
      expect(subject.eligible?(options2)).to be false
    end
  end

  describe '#description' do
    context 'when min extra adults equals max extra adults' do
      it 'returns the correct description' do
        subject.preferred_min_extra_adults = 1
        subject.preferred_max_extra_adults = 1

        expect(subject.description).to eq('Booking with extra 1 adults')
      end
    end

    context 'when min extra adults is not equal to max extra adults' do
      it 'returns the correct description' do
        subject.preferred_min_extra_adults = 1
        subject.preferred_max_extra_adults = 3

        expect(subject.description).to eq('Booking with extra 1-3 adults')
      end
    end
  end
end
