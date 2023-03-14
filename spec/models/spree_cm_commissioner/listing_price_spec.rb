require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ListingPrice, type: :model do
  describe 'associations' do
    it { should have_many(:adjustments).class_name('Spree::Adjustment').dependent(:destroy) }

    it { is_expected.to belong_to(:price_source) }
  end

  describe 'validations' do
    it { should validate_presence_of(:date) }
  end
end
