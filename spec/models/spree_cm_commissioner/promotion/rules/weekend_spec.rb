require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::Weekend do
  let(:monday) { '2023-11-13'.to_date }
  let(:tuesday) { '2023-11-14'.to_date }
  let(:wednesday) { '2023-11-15'.to_date }
  let(:thursday) { '2023-11-16'.to_date }
  let(:friday) { '2023-11-17'.to_date }

  let(:saturday) { '2023-11-18'.to_date }
  let(:sunday) { '2023-11-19'.to_date }

  describe 'date_eligible?' do
    it 'eligible when wday is in preferred_weekend_days' do
      subject = described_class.new(preferred_weekend_days: ['5', '6', '0'])

      expect(friday.wday).to eq 5
      expect(saturday.wday).to eq 6
      expect(sunday.wday).to eq 0

      expect(subject.date_eligible?(friday)).to be true
      expect(subject.date_eligible?(saturday)).to be true
      expect(subject.date_eligible?(sunday)).to be true
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
end
