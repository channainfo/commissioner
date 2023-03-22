require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ServiceCalendar, type: :model do
  context 'associations' do
    it { should belong_to(:calendarable) }
  end

  context 'validations' do
    let(:calendar)   { build(:cm_service_calendar) }
    let(:valid_rule) { {from: date('2023-01-01'), to: date('2023-01-02'), type: 'exclusion', reason: 'company retreat'} }

    context 'exception_rules valid' do
      it 'empty rules' do
        calendar.exception_rules = []
        expect(calendar).to be_valid
      end

      it 'valid rules' do
        calendar.exception_rules = [valid_rule]
        expect(calendar).to be_valid
      end

      it 'no reason' do
        valid_rule.delete(:reason)
        calendar.exception_rules = [valid_rule]
        expect(calendar).to be_valid
      end
    end

    context 'exception_rules invalid' do
      it 'no from date' do
        valid_rule.delete(:from)
        calendar.exception_rules = [valid_rule]
        expect(calendar).to be_invalid
      end

      it 'no to date' do
        valid_rule.delete(:to)
        calendar.exception_rules = [valid_rule]
        expect(calendar).to be_invalid
      end

      it 'no type' do
        valid_rule.delete(:type)
        calendar.exception_rules = [valid_rule]
        expect(calendar).to be_invalid
      end

      it 'from is not date format' do
        valid_rule[:from] = '2023-01'
        calendar.exception_rules = [valid_rule]
        expect(calendar).to be_invalid
      end
    end
  end

  context 'service calendar' do
    let(:monday) { date('2023-01-02') }
    it 'is open on Monday' do
      service_calendar = create(:cm_service_calendar, monday: true)
      expect(service_calendar.service_available?(monday)).to eq true
    end

    it 'is closed on Monday' do
      service_calendar = create(:cm_service_calendar, monday: false)
      expect(service_calendar.service_available?(monday)).to eq false
    end

    it 'is closed outside of date range' do
      service_calendar = create(:cm_service_calendar, start_date: date('2023-02-01'), end_date: date('2023-03-01'))

      expect(service_calendar.service_available?(date('2023-01-01'))).to eq false
      expect(service_calendar.service_available?(date('2023-04-01'))).to eq false
    end
  end

  context 'exception rule' do
    let(:exception_rules) { [
        {from: date('2022-01-01'), to: date('2022-01-30'), type: 'inclusion' },
        {from: date('2023-01-02'), to: date('2023-01-02'), type: 'exclusion' },
      ]
    }
    let(:service_calendar) { create(:cm_service_calendar, exception_rules: exception_rules) }

    it 'inclusion' do
      expect(service_calendar.service_available?(date('2022-01-02'))).to eq true
    end

    it 'exclusion' do
      calendar = create(:cm_service_calendar, exception_rules: exception_rules)
      expect(calendar.service_available?(date('2023-01-02'))).to eq false
    end

    it 'no date in expection_rules' do
      expect(service_calendar.service_available?(date('2024-01-01'))).to eq true # normal service
    end
  end
end
