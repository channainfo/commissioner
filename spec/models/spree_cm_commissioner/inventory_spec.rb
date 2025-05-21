require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Inventory, type: :model do
  subject { described_class.new(variant_id: 1, inventory_date: Date.today, quantity_available: 10, max_capacity: 100, product_type: 'accommodation') }

  it 'includes ActiveModel::Model' do
    expect(described_class.ancestors).to include(ActiveModel::Model)
  end

  describe 'attributes' do
    it 'has a variant_id' do
      expect(subject.variant_id).to eq(1)
    end

    it 'has an inventory_date' do
      expect(subject.inventory_date).to eq(Date.today)
    end

    it 'has a quantity_available' do
      expect(subject.quantity_available).to eq(10)
    end

    it 'has a max_capacity' do
      expect(subject.max_capacity).to eq(100)
    end

    it 'has a product_type' do
      expect(subject.product_type).to eq('accommodation')
    end
  end

  describe 'validations' do
    context 'variant_id' do
      it 'is valid with a variant_id' do
        expect(subject).to be_valid
      end

      it 'is invalid without a variant_id' do
        subject.variant_id = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:variant_id]).to include("can't be blank")
      end
    end

    context 'quantity_available' do
      it 'is valid with a positive integer' do
        subject.quantity_available = 5
        expect(subject).to be_valid
      end

      it 'is valid with zero' do
        subject.quantity_available = 0
        expect(subject).to be_valid
      end

      it 'is valid when nil' do
        subject.quantity_available = nil
        expect(subject).to be_valid
      end

      it 'is invalid with a negative integer' do
        subject.quantity_available = -1
        expect(subject).not_to be_valid
        expect(subject.errors[:quantity_available]).to include('must be greater than or equal to 0')
      end

      it 'is invalid with a non-integer value' do
        subject.quantity_available = 10.5
        expect(subject).not_to be_valid
        expect(subject.errors[:quantity_available]).to include('must be an integer')
      end
    end

    context 'max_capacity' do
      it 'is valid with a positive integer' do
        subject.max_capacity = 50
        expect(subject).to be_valid
      end

      it 'is valid with zero' do
        subject.max_capacity = 0
        expect(subject).to be_valid
      end

      it 'is valid when nil' do
        subject.max_capacity = nil
        expect(subject).to be_valid
      end

      it 'is invalid with a negative integer' do
        subject.max_capacity = -10
        expect(subject).not_to be_valid
        expect(subject.errors[:max_capacity]).to include('must be greater than or equal to 0')
      end

      it 'is invalid with a non-integer value' do
        subject.max_capacity = 100.5
        expect(subject).not_to be_valid
        expect(subject.errors[:max_capacity]).to include('must be an integer')
      end
    end
  end

  # Test initialization with custom attributes
  describe 'initialization' do
    let(:inventory) do
      described_class.new(
        variant_id: 2,
        inventory_date: Date.new(2025, 3, 27),
        quantity_available: 20,
        max_capacity: 50,
        product_type: 'accommodation'
      )
    end

    it 'sets attributes correctly' do
      expect(inventory.variant_id).to eq(2)
      expect(inventory.inventory_date).to eq(Date.new(2025, 3, 27))
      expect(inventory.quantity_available).to eq(20)
      expect(inventory.max_capacity).to eq(50)
      expect(inventory.product_type).to eq('accommodation')
    end
  end
end
