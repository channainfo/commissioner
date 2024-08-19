require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ProductPlace, type: :model do
  describe 'associations' do
    it { should belong_to(:product).class_name('Spree::Product').optional }
    it { should belong_to(:place).class_name('SpreeCmCommissioner::Place').optional }
  end
end