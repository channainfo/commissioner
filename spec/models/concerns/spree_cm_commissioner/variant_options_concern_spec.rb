require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VariantOptionsConcern do
  let(:option_values) { [option_value] }
  let(:variant) { create(:variant, option_values: option_values) }

  context 'callback :before_save' do
    let(:option_type1) { create(:cm_option_type, name: 'color') }
    let(:option_type2) { create(:cm_option_type, name: 'storage') }

    let(:option_value1) { create(:cm_option_value, name: 'red', option_type: option_type1) }
    let(:option_value2) { create(:cm_option_value, name: '256GB', option_type: option_type2) }

    let(:variant) { build(:variant, option_values: [option_value1, option_value2]) }

    describe '#set_options_to_public_metadata' do
      it 'save latest option values to public_metadata[:cm_options]' do
        expect(variant).to receive(:set_options_to_public_metadata).and_call_original

        variant.save!

        expect(variant.public_metadata[:cm_options]).to eq({'color' => 'red', 'storage' => '256GB'})
        expect(variant.options_in_hash).to eq variant.public_metadata[:cm_options]
      end
    end
  end

  describe '#option_value_name_for' do
    let(:option_type1) { create(:cm_option_type, name: 'color') }
    let(:option_type2) { create(:cm_option_type, name: 'storage') }

    let(:option_value1) { create(:cm_option_value, name: 'red', option_type: option_type1) }
    let(:option_value2) { create(:cm_option_value, name: '256GB', option_type: option_type2) }

    let(:variant) { create(:variant, option_values: [option_value1, option_value2]) }

    context 'when options already saved in public_metadata' do
      it 'read option value from options_in_hash' do
        expect(variant.public_metadata[:cm_options]).to eq({'color' => 'red', 'storage' => '256GB'})

        expect(variant).to receive(:options_in_hash).twice.and_call_original
        expect(variant).to_not receive(:find_option_value_name_for)

        expect(variant.option_value_name_for(option_type_name: 'color')).to eq 'red'
      end
    end

    # mostly this case only for old variants.
    context 'when options not yet save to public_metadata' do
      it 'read option value from find_option_value_name_for to look in db' do
        variant.update_column(:public_metadata, {})

        expect(variant.public_metadata[:cm_options]).to eq(nil)
        expect(variant.options_in_hash).to eq(nil)

        expect(variant).to receive(:find_option_value_name_for).with(option_type_name: 'color').and_call_original

        expect(variant.option_value_name_for(option_type_name: 'color')).to eq 'red'
      end
    end
  end

  describe "#post_paid?" do
    let(:option_type) { create(:cm_option_type, :payment_option) }
    let(:option_value) { create(:cm_option_value, name: 'post-paid', option_type: option_type) }

    before do
      # just to make sure it not find option value via db.
      expect(variant).to_not receive(:find_option_value_name_for)
    end

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

    before do
      # just to make sure it not find option value via db.
      expect(variant).to_not receive(:find_option_value_name_for)
    end

    it 'combine start_date & start_time' do
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

    before do
      # just to make sure it not find option value via db.
      expect(variant).to_not receive(:find_option_value_name_for)
    end

    it 'conbine end_date & end_time' do
      expect(variant.end_date_time).to eq Time.zone.parse('2024-02-02 05:00:00')
    end
  end

  describe '#start_date' do
    let(:option_type) { create(:cm_option_type, :start_date) }
    let(:option_value) { create(:cm_option_value, name: '2024-01-01', option_type: option_type) }

    before do
      # just to make sure it not find option value via db.
      expect(variant).to_not receive(:find_option_value_name_for)
    end

    context 'when variant has [start_date] option value' do
      let(:product) { create(:product, option_types: [option_type]) }
      let(:variant) { create(:variant, product: product, option_values: [option_value]) }

      it 'return start_date of option value' do
        expect(variant.options.start_date).to eq '2024-01-01'.to_date
        expect(variant.start_date).to eq '2024-01-01'.to_date
      end
    end

    context 'when variant has no [start_date] option value' do
      let(:product) { create(:product) }
      let(:variant) { create(:variant, product: product) }

      it 'return start_date nil' do
        expect(variant.options.start_date).to eq nil
        expect(variant.start_date).to eq nil
      end
    end
  end

  describe '#end_date' do
    before do
      # just to make sure it not find option value via db.
      expect(variant).to_not receive(:find_option_value_name_for)
    end

    let(:option_type) { create(:cm_option_type, :end_date) }
    let(:option_value) { create(:cm_option_value, name: '2024-01-01', option_type: option_type) }

    context 'when variant has [end_date] option value' do
      let(:product) { create(:product, option_types: [option_type]) }
      let(:variant) { create(:variant, product: product, option_values: [option_value]) }

      it 'return end_date of option value' do
        expect(variant.options.end_date).to eq '2024-01-01'.to_date
        expect(variant.end_date).to eq '2024-01-01'.to_date
      end
    end

    context 'when no [end_date] option value' do
      let(:product) { create(:product) }
      let(:variant) { create(:variant, product: product) }

      it 'return end_date nil' do
        expect(variant.options.end_date).to eq nil
        expect(variant.end_date).to eq nil
      end
    end

    context 'when [start_date] option value & [duration] option values' do
      let(:start_date) { create(:cm_option_type, :start_date) }
      let(:duration_in_hours) { create(:cm_option_type, :duration_in_hours) }
      let(:duration_in_minutes) { create(:cm_option_type, :duration_in_minutes) }
      let(:duration_in_seconds) { create(:cm_option_type, :duration_in_seconds) }

      let(:start_date_option_value) { create(:cm_option_value, name: '2024-01-01', option_type: start_date) }
      let(:two_hours) { create(:cm_option_value, name: '2', option_type: duration_in_hours) }
      let(:thirdty_minutes) { create(:cm_option_value, name: '30', option_type: duration_in_minutes) }
      let(:sixty_seconds) { create(:cm_option_value, name: '60', option_type: duration_in_seconds) }

      let(:product) { create(:product, option_types: [start_date, duration_in_hours, duration_in_minutes, duration_in_seconds]) }
      let(:variant) { create(:variant, product: product, option_values: [start_date_option_value, option_value, two_hours, thirdty_minutes, sixty_seconds]) }

      it 'return end date combine of start_date + durations' do
        expect(variant.end_date).to eq '2024-01-01'.to_date + 2.hours + 30.minutes + 60.seconds
      end
    end
  end

  describe '#start_time' do
    let(:option_type) { create(:cm_option_type, :start_time) }
    let(:option_value) { create(:cm_option_value, name: '03:00:00', option_type: option_type) }

    before do
      # just to make sure it not find option value via db.
      expect(variant).to_not receive(:find_option_value_name_for)
    end

    context 'when variant has [start_time] option value' do
      let(:product) { create(:product, option_types: [option_type]) }
      let(:variant) { create(:variant, product: product, option_values: [option_value]) }

      it 'return start_time of option value' do
        expect(variant.options.start_time).to eq Time.zone.parse('03:00:00')
        expect(variant.start_time.strftime('%H:%M:%S')).to eq '03:00:00'
      end
    end

    context 'when variant has no [start_time] option value' do
      let(:product) { create(:product) }
      let(:variant) { create(:variant, product: product) }

      it 'return start_time nil' do
        expect(variant.options.start_time).to eq nil
        expect(variant.start_time).to eq nil
      end
    end
  end

  describe '#end_time' do
    before do
      # just to make sure it not find option value via db.
      expect(variant).to_not receive(:find_option_value_name_for)
    end

    context 'when variant has [end_time] option value' do
      let(:option_type) { create(:cm_option_type, :end_time) }
      let(:option_value) { create(:cm_option_value, name: '03:00:00', option_type: option_type) }

      let(:product) { create(:product, option_types: [option_type]) }
      let(:variant) { create(:variant, product: product, option_values: [option_value]) }

      it 'return end_time of option value' do
        expect(variant.options.end_time).to eq Time.zone.parse('03:00:00')
        expect(variant.end_time.strftime('%H:%M:%S')).to eq '03:00:00'
      end
    end

    context 'when variant start time & duration option values' do
      let(:start_time) { create(:cm_option_type, :start_time) }
      let(:start_time_option_value) { create(:cm_option_value, name: '03:00:00', option_type: start_time) }

      let(:duration_in_hours) { create(:cm_option_type, :duration_in_hours) }
      let(:duration_in_minutes) { create(:cm_option_type, :duration_in_minutes) }
      let(:duration_in_seconds) { create(:cm_option_type, :duration_in_seconds) }

      let(:two_hours) { create(:cm_option_value, name: '2', option_type: duration_in_hours) }
      let(:thirdty_minutes) { create(:cm_option_value, name: '30', option_type: duration_in_minutes) }
      let(:sixty_seconds) { create(:cm_option_value, name: '55', option_type: duration_in_seconds) }

      let(:product) { create(:product, option_types: [start_time, duration_in_hours, duration_in_minutes, duration_in_seconds]) }
      let(:variant) { create(:variant, product: product, option_values: [start_time_option_value, two_hours, thirdty_minutes, sixty_seconds]) }

      it 'end date combine of from_date + durations' do
        expect(variant.end_time.strftime('%H:%M:%S')).to eq('05:30:55')
      end
    end

    context 'when variant has no [end_time] option value or [start_time] [duration] option value' do
      let(:product) { create(:product) }
      let(:variant) { create(:variant, product: product) }

      it 'return null' do
        expect(variant.options.end_time).to eq nil
        expect(variant.end_time).to eq nil
      end
    end
  end
end
