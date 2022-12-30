require 'spec_helper'

RSpec.describe Spree::Prototype, type: :model do
  describe '#product_type' do
    it 'raise error on enter invalid product_type' do
      expect{create(:prototype, product_type: :fake)}
        .to raise_error(ArgumentError)
        .with_message("'fake' is not a valid product_type")
    end

    it 'raise error when input primary_product_type instead of product_type' do
      expect{create(:prototype, primary_product_type: described_class.product_types[0])}.to raise_error { |error|
        expect(error).to be_a(NoMethodError)
        expect(error.message).to include('undefined method `primary_product_type=')
      }
    end

    it 'save on input valid product_type' do
      prototype = build(:prototype, product_type: described_class.product_types[0])
      expect(prototype.save!).to be true
    end
  end
end