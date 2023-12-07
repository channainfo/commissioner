require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::CustomDates do
  let(:date1) { "2023-08-01".to_date }
  let(:date2) { "2023-09-01".to_date }
  let(:date3) { "2023-10-01".to_date }

  let(:custom_date1) { { start_date: date1, length: '2', title: 'Holiday1' }.to_json }
  let(:custom_date2) { { start_date: date2, length: '1', title: 'Holiday2' }.to_json }
  let(:custom_date3) { { start_date: date3, length: '1', title: 'Holiday3' }.to_json }

  let(:preferred_custom_dates) { [custom_date1, custom_date2, custom_date3]}

  describe '#date_eligible?' do
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

  context 'before_update callbacks' do
    let(:custom_date_7th) { { start_date: '2023-11-07'.to_date, length: '1', title: 'Holiday1' }.to_json }
    let(:custom_date_8th) { { start_date: '2023-11-08'.to_date, length: '1', title: 'Holiday2' }.to_json }

    describe '#sort_custom_dates' do
      it 'does not run callback if custom_dates not exists' do
        promotion_rule = described_class.new
        allow(promotion_rule).to receive(:sort_custom_dates)

        expect(promotion_rule.preferred_custom_dates).to eq nil
        expect(promotion_rule).not_to have_received(:sort_custom_dates)
      end

      it 'sorted custom dates by their start date' do
        promotion_rule = described_class.create

        promotion_rule.update(preferred_custom_dates: [custom_date_8th, custom_date_7th])
        promotion_rule.reload

        expect(promotion_rule.preferred_custom_dates).to eq [custom_date_7th, custom_date_8th]
      end
    end
  end
end
