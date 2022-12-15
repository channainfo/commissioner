require 'spec_helper'

RSpec.describe Spree::OptionType, type: :model do
  describe 'associations' do
    it { should have_many(:option_values).class_name('Spree::OptionValue').dependent(:destroy) }
  end

  describe 'validations' do
    it 'raise error on update is_master after created' do
      option_type = create(:option_type, is_master: true)
      option_type.is_master = false

      expect(option_type.is_master_changed?).to eq true
      expect{option_type.save!}.to raise_error ActiveRecord::RecordInvalid
    end
  end
end