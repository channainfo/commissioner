require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::Weekend do
  let(:monday) { '2023-11-13'.to_date }
  let(:tuesday) { '2023-11-14'.to_date }
  let(:wednesday) { '2023-11-15'.to_date }
  let(:thursday) { '2023-11-16'.to_date }
  let(:friday) { '2023-11-17'.to_date }

  let(:saturday) { '2023-11-18'.to_date }
  let(:sunday) { '2023-11-19'.to_date }

  describe '#date_eligible?' do
    it 'eligible when wday is in preferred_weekend_days' do
      subject = described_class.new(preferred_weekend_days: ['5', '6', '0'])

      expect(friday.wday).to eq 5
      expect(saturday.wday).to eq 6
      expect(sunday.wday).to eq 0

      expect(subject.date_eligible?(friday)).to be true
      expect(subject.date_eligible?(saturday)).to be true
      expect(subject.date_eligible?(sunday)).to be true
    end

    it 'not eligible when date is weekend but is exception date' do
      exception_date = { start_date: friday, length: '1', title: 'Holiday' }.to_json
      subject = described_class.new(preferred_weekend_days: ['5', '6', '0'], preferred_exception_dates: [exception_date])

      expect(subject.weekend?(friday)).to be true
      expect(subject.exception?(friday)).to be true

      expect(subject.date_eligible?(friday)).to be false
    end

    it 'not eligible on weekday' do
      subject = described_class.new(preferred_weekend_days: ['6', '0'])

      expect(subject.date_eligible?(monday)).to be false
      expect(subject.date_eligible?(tuesday)).to be false
      expect(subject.date_eligible?(wednesday)).to be false
      expect(subject.date_eligible?(thursday)).to be false
      expect(subject.date_eligible?(friday)).to be false
    end
  end

  context 'before_update callbacks' do
    let(:exception_date_7th) { { start_date: '2023-11-07'.to_date, length: '1', title: 'Holiday1' }.to_json }
    let(:exception_date_8th) { { start_date: '2023-11-08'.to_date, length: '1', title: 'Holiday2' }.to_json }

    describe '#sort_exception_dates' do
      it 'does not run callback if exception_dates not exists' do
        weekend_rule = described_class.new
        allow(weekend_rule).to receive(:sort_exception_dates)

        expect(weekend_rule.preferred_exception_dates).to eq nil
        expect(weekend_rule).not_to have_received(:sort_exception_dates)
      end

      it 'sorted exception dates by their start date' do
        weekend_rule = described_class.create

        weekend_rule.update(preferred_exception_dates: [exception_date_8th, exception_date_7th])
        weekend_rule.reload

        expect(weekend_rule.preferred_exception_dates).to eq [exception_date_7th, exception_date_8th]
      end
    end
  end
end
