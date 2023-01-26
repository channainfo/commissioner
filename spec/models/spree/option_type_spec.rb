require 'spec_helper'

RSpec.describe Spree::OptionType, type: :model do
  describe 'associations' do
    it { should have_many(:option_values).class_name('Spree::OptionValue').dependent(:destroy) }
  end

  describe 'test scope and validation' do
    it { should validate_presence_of(:presentation) }
    it { should validate_presence_of(:name) }

    describe '.promoted' do
      it 'return only promoted option types' do
        option_type1 = create(:option_type, promoted: true)
        option_type2 = create(:option_type, promoted: false)
  
        expect(described_class.promoted.size).to eq 1
        expect(described_class.promoted.first).to eq option_type1
      end
    end
  end

  describe 'validations' do
    it 'saved on [attr_type] is included in ATTRIBUTE_TYPES' do
      expect{create(:option_type, attr_type: 'float')}.to_not raise_error
      expect{create(:option_type, attr_type: 'integer')}.to_not raise_error
      expect{create(:option_type, attr_type: 'string')}.to_not raise_error
      expect{create(:option_type, attr_type: 'boolean')}.to_not raise_error
      expect{create(:option_type, attr_type: 'date')}.to_not raise_error
      expect{create(:option_type, attr_type: 'coordinate')}.to_not raise_error
    end

    it 'raise error on [attr_type] is not included in ATTRIBUTE_TYPES' do
      option_type = build(:option_type, attr_type: 'fake-type')
      expect{option_type.save!}.to raise_error ActiveRecord::RecordInvalid
    end

    it 'raise error on update kind after created' do
      option_type = create(:option_type, kind: :variant)
      option_type.kind = :vendor

      expect(option_type.vendor?).to eq true
      expect(option_type.kind_changed?).to eq true
      expect{option_type.save!}.to raise_error ActiveRecord::RecordInvalid
    end
  end
end