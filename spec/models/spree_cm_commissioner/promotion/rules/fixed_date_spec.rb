require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::FixedDate do
  let(:date_in_string) { '2023-11-13' }

  subject { described_class.new(preferred_start_date: date_in_string, preferred_length: 2) }

  describe '#start_rule_date' do
    it 'return start_rule_date in date object' do
      expect(subject.start_rule_date).to eq date_in_string.to_date
    end
  end

  describe '#end_rule_date' do
    it 'return end date 1 day after start date (total length is 2)' do
      expect(subject.end_rule_date).to eq '2023-11-14'.to_date
    end
  end

  describe '#date_eligible' do
    it 'eligible when input date is between start to end date' do
      expect(subject.date_eligible? '2023-11-13'.to_date).to be true
      expect(subject.date_eligible? '2023-11-14'.to_date).to be true
    end

    it 'eligible when input date is not between start to end date' do
      expect(subject.date_eligible? '2023-11-15'.to_date).to be false
    end
  end
end
