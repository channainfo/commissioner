require 'spec_helper'

RSpec.describe Spree::OptionType, type: :model do
  describe 'associations' do
    it { should have_many(:option_values).class_name('Spree::OptionValue').dependent(:destroy) }
  end

  describe 'test scope and validation' do
    it { should validate_presence_of(:presentation) }
    it { should validate_presence_of(:name) }
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

    it 'raise error on update is_master after created' do
      option_type = create(:option_type, is_master: true)
      option_type.is_master = false

      expect(option_type.is_master_changed?).to eq true
      expect{option_type.save!}.to raise_error ActiveRecord::RecordInvalid
    end
  end
end