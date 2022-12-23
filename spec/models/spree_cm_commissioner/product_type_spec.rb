require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ProductType, type: :model do
  let(:product_type) { create(:product_type) }

  describe 'validation' do
    it 'does not allow duplicate names' do
      product_type = create(:product_type, name: "Service")
      expect(build(:product_type, name: "Service")).not_to be_valid
    end
  end
end
