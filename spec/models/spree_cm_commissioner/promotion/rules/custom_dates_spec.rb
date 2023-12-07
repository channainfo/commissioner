require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::CustomDates do
  let(:date1) { "2023-08-01".to_date }
  let(:date2) { "2023-09-01".to_date }
  let(:date3) { "2023-10-01".to_date }

  let(:custom_date1) { { start_date: date1, length: '2', title: 'Holiday1' }.to_json }
  let(:custom_date2) { { start_date: date2, length: '1', title: 'Holiday2' }.to_json }
  let(:custom_date3) { { start_date: date3, length: '1', title: 'Holiday3' }.to_json }

  let(:preferred_custom_dates) { [custom_date1, custom_date2, custom_date3]}

  describe 'date_eligible?' do
    it 'eligible when date is between any of custom_dates' do
      subject = described_class.create(preferred_custom_dates: preferred_custom_dates)

      expect(subject.date_eligible?(date1)).to be true
      expect(subject.date_eligible?(date1 + 1.days)).to be true

      expect(subject.date_eligible?(date2)).to be true
      expect(subject.date_eligible?(date3)).to be true
    end

    it 'not eligible when date is ahead of custom dates range' do
      subject = described_class.create(preferred_custom_dates: preferred_custom_dates)

      expect(subject.date_eligible?(date1 + 2.days)).to be false
      expect(subject.date_eligible?(date2 + 1.days)).to be false
      expect(subject.date_eligible?(date3 + 1.days)).to be false
    end

    it 'not when date is not between any of custom dates' do
      subject = described_class.create(preferred_custom_dates: [custom_date1])

      expect(subject.date_eligible?('2023-01-01'.to_date)).to be false
    end
  end
end
