require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::Weekend do
  subject { described_class.new }

  let(:monday) { '2023-11-13'.to_date }
  let(:tuesday) { '2023-11-14'.to_date }
  let(:wednesday) { '2023-11-15'.to_date }
  let(:thursday) { '2023-11-16'.to_date }
  let(:friday) { '2023-11-17'.to_date }

  let(:saturday) { '2023-11-18'.to_date }
  let(:sunday) { '2023-11-19'.to_date }

  describe 'date_eligible?' do
    it 'eligible on saturday and sunday' do
      expect(saturday.on_weekend?).to be true
      expect(sunday.on_weekend?).to be true

      expect(subject.date_eligible?(saturday)).to be true
      expect(subject.date_eligible?(sunday)).to be true
    end

    it 'not eligible on weekday' do
      expect(monday.on_weekend?).to be false
      expect(tuesday.on_weekend?).to be false
      expect(wednesday.on_weekend?).to be false
      expect(thursday.on_weekend?).to be false
      expect(friday.on_weekend?).to be false

      expect(subject.date_eligible?(monday)).to be false
      expect(subject.date_eligible?(tuesday)).to be false
      expect(subject.date_eligible?(wednesday)).to be false
      expect(subject.date_eligible?(thursday)).to be false
      expect(subject.date_eligible?(friday)).to be false
    end
  end
end
