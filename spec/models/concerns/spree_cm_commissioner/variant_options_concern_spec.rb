require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VariantOptionsConcern do
  let(:option_values) { [option_value] }
  let(:variant) { create(:variant, option_values: option_values) }

  describe "#post_paid?" do
    let(:option_type) { create(:cm_option_type, :payment_option) }
    let(:option_value) { create(:cm_option_value, name: 'post-paid', option_type: option_type) }

    it 'return true when payment_option is post-paid' do
      expect(variant.payment_option).to eq 'post-paid'
      expect(variant.post_paid?).to be true
    end
  end

  describe '#start_date_time' do
    let(:option_type1) { create(:cm_option_type, :start_date) }
    let(:option_value1) { create(:cm_option_value, name: '2024-01-01', option_type: option_type1) }

    let(:option_type2) { create(:cm_option_type, :start_time) }
    let(:option_value2) { create(:cm_option_value, name: '03:00:00', option_type: option_type2) }

    let(:product) { create(:product, option_types: [option_type1, option_type2]) }
    let(:variant) { create(:variant, product: product, option_values: [option_value1, option_value2]) }

    it 'conbine start_date & start_time' do
      expect(variant.start_date_time).to eq Time.zone.parse('2024-01-01 03:00:00')
    end
  end

  describe '#end_date_time' do
    let(:option_type1) { create(:cm_option_type, :end_date) }
    let(:option_value1) { create(:cm_option_value, name: '2024-02-02', option_type: option_type1) }

    let(:option_type2) { create(:cm_option_type, :end_time) }
    let(:option_value2) { create(:cm_option_value, name: '05:00:00', option_type: option_type2) }

    let(:product) { create(:product, option_types: [option_type1, option_type2]) }
    let(:variant) { create(:variant, product: product, option_values: [option_value1, option_value2]) }

    it 'conbine end_date & end_time' do
      expect(variant.end_date_time).to eq Time.zone.parse('2024-02-02 05:00:00')
    end
  end

  describe '#start_date' do
    let(:section) { create(:cm_taxon_event_section, from_date: '2024-02-02'.to_date, to_date: '2024-03-03') }
    let(:option_type) { create(:cm_option_type, :start_date) }
    let(:option_value) { create(:cm_option_value, name: '2024-01-01', option_type: option_type) }

    context 'when variant has event & [start_date] option value' do
      let(:product) { create(:product, option_types: [option_type], taxons: [section]) }
      let(:variant) { create(:variant, product: product, option_values: [option_value]) }

      it 'return start_date of option value' do
        expect(variant.event.from_date).to eq '2024-02-02'.to_date
        expect(variant.options.start_date).to eq '2024-01-01'.to_date

        expect(variant.start_date).to eq '2024-01-01'.to_date
      end
    end

    context 'when variant has event & no [start_date] option value' do
      let(:product) { create(:product, taxons: [section]) }
      let(:variant) { create(:variant, product: product) }

      it 'return start_date of event' do
        expect(variant.event.from_date).to eq '2024-02-02'.to_date
        expect(variant.options.start_date).to eq nil

        expect(variant.start_date).to eq '2024-02-02'.to_date
      end
    end

    context 'when variant has no event & no [start_date] option value' do
      let(:product) { create(:product) }
      let(:variant) { create(:variant, product: product) }

      it 'return null' do
        expect(variant.event&.from_date).to eq nil
        expect(variant.options.start_date).to eq nil

        expect(variant.start_date).to eq nil
      end
    end
  end

  describe '#end_date' do
    context 'when variant has duration option values' do
      let(:section) { create(:cm_taxon_event_section, from_date: '2024-02-02') }

      let(:duration_in_hours) { create(:cm_option_type, :duration_in_hours) }
      let(:duration_in_minutes) { create(:cm_option_type, :duration_in_minutes) }
      let(:duration_in_seconds) { create(:cm_option_type, :duration_in_seconds) }

      let(:two_hours) { create(:cm_option_value, name: '2', option_type: duration_in_hours) }
      let(:thirdty_minutes) { create(:cm_option_value, name: '30', option_type: duration_in_minutes) }
      let(:sixty_seconds) { create(:cm_option_value, name: '60', option_type: duration_in_seconds) }

      let(:product) { create(:product, taxons: [section], option_types: [duration_in_hours, duration_in_minutes, duration_in_seconds]) }
      let(:variant) { create(:variant, product: product, option_values: [two_hours, thirdty_minutes, sixty_seconds]) }

      it 'end date combine of start_date + durations' do
        expect(variant.end_date).to eq '2024-02-02'.to_date + 2.hours + 30.minutes + 60.seconds
      end
    end

    context 'when variant has no duration option values' do
      let(:section) { create(:cm_taxon_event_section, from_date: '2024-02-02', to_date: '2024-03-03') }
      let(:option_type) { create(:cm_option_type, :end_date) }
      let(:option_value) { create(:cm_option_value, name: '2024-01-01', option_type: option_type) }

      context 'when variant has event & [end_date] option value' do
        let(:product) { create(:product, option_types: [option_type], taxons: [section]) }
        let(:variant) { create(:variant, product: product, option_values: [option_value]) }

        it 'return end_date of option value' do
          expect(variant.event.to_date).to eq '2024-03-03'.to_date
          expect(variant.options.end_date).to eq '2024-01-01'.to_date

          expect(variant.end_date).to eq '2024-01-01'.to_date
        end
      end

      context 'when variant has event & no [end_date] option value' do
        let(:product) { create(:product, taxons: [section]) }
        let(:variant) { create(:variant, product: product) }

        it 'return end_date of event' do
          expect(variant.event.to_date).to eq '2024-03-03'.to_date
          expect(variant.options.end_date).to eq nil

          expect(variant.end_date).to eq '2024-03-03'.to_date
        end
      end

      context 'when variant has no event & no [end_date] option value' do
        let(:product) { create(:product) }
        let(:variant) { create(:variant, product: product) }

        it 'return null' do
          expect(variant.event&.from_date).to eq nil
          expect(variant.options.end_date).to eq nil

          expect(variant.end_date).to eq nil
        end
      end
    end
  end

  describe '#start_time' do
    let(:section) { create(:cm_taxon_event_section, from_date: '2024-02-02 13:00:00', to_date: '2024-03-03 17:00:00') }
    let(:option_type) { create(:cm_option_type, :start_time) }
    let(:option_value) { create(:cm_option_value, name: '03:00:00', option_type: option_type) }

    context 'when variant has event & [start_time] option value' do
      let(:product) { create(:product, option_types: [option_type], taxons: [section]) }
      let(:variant) { create(:variant, product: product, option_values: [option_value]) }

      it 'return start_time of option value' do
        expect(variant.event.from_date).to eq Time.zone.parse('2024-02-02 13:00:00')
        expect(variant.options.start_time).to eq Time.zone.parse('03:00:00')

        expect(variant.start_time.strftime('%H:%M:%S')).to eq '03:00:00'
      end
    end

    context 'when variant has event & no [start_time] option value' do
      let(:product) { create(:product, taxons: [section]) }
      let(:variant) { create(:variant, product: product) }

      it 'return start_time of event instead' do
        expect(variant.event.from_date).to eq Time.zone.parse('2024-02-02 13:00:00')
        expect(variant.options.start_time).to eq nil

        expect(variant.start_time.strftime('%H:%M:%S')).to eq '13:00:00'
      end
    end

    context 'when variant has no event & no [start_time] option value' do
      let(:product) { create(:product) }
      let(:variant) { create(:variant, product: product) }

      it 'return null' do
        expect(variant.event&.from_date).to eq nil
        expect(variant.options.start_time).to eq nil

        expect(variant.start_time).to eq nil
      end
    end
  end

  describe '#end_time' do
    context 'when variant has duration option values' do
      let(:section) { create(:cm_taxon_event_section, from_date: '2024-02-02 03:00:00') }

      let(:duration_in_hours) { create(:cm_option_type, :duration_in_hours) }
      let(:duration_in_minutes) { create(:cm_option_type, :duration_in_minutes) }
      let(:duration_in_seconds) { create(:cm_option_type, :duration_in_seconds) }

      let(:two_hours) { create(:cm_option_value, name: '2', option_type: duration_in_hours) }
      let(:thirdty_minutes) { create(:cm_option_value, name: '30', option_type: duration_in_minutes) }
      let(:sixty_seconds) { create(:cm_option_value, name: '60', option_type: duration_in_seconds) }

      let(:product) { create(:product, taxons: [section], option_types: [duration_in_hours, duration_in_minutes, duration_in_seconds]) }
      let(:variant) { create(:variant, product: product, option_values: [two_hours, thirdty_minutes, sixty_seconds]) }

      it 'end date combine of from_date + durations' do
        expect(variant.end_time.strftime('%H:%M:%S')).to eq('05:31:00')
      end
    end

    context 'when variant has no duration option values' do
      let(:section) { create(:cm_taxon_event_section, from_date: '2024-02-02 13:00:00', to_date: '2024-03-03 17:00:00') }
      let(:option_type) { create(:cm_option_type, :end_time) }
      let(:option_value) { create(:cm_option_value, name: '03:00:00', option_type: option_type) }

      context 'when variant has event & [end_time] option value' do
        let(:product) { create(:product, option_types: [option_type], taxons: [section]) }
        let(:variant) { create(:variant, product: product, option_values: [option_value]) }

        it 'return end_time of option value' do
          expect(variant.event.to_date).to eq Time.zone.parse('2024-03-03 17:00:00')
          expect(variant.options.end_time).to eq Time.zone.parse('03:00:00')

          expect(variant.end_time.strftime('%H:%M:%S')).to eq '03:00:00'
        end
      end

      context 'when variant has event & no [end_time] option value' do
        let(:product) { create(:product, taxons: [section]) }
        let(:variant) { create(:variant, product: product) }

        it 'return end_time of event instead' do
          expect(variant.event.to_date).to eq Time.zone.parse('2024-03-03 17:00:00')
          expect(variant.options.end_time).to eq nil

          expect(variant.end_time.strftime('%H:%M:%S')).to eq '17:00:00'
        end
      end

      context 'when variant has no event & no [end_time] option value' do
        let(:product) { create(:product) }
        let(:variant) { create(:variant, product: product) }

        it 'return null' do
          expect(variant.event&.from_date).to eq nil
          expect(variant.options.end_time).to eq nil

          expect(variant.end_time).to eq nil
        end
      end
    end
  end
end
