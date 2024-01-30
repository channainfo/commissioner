require "spec_helper"

RSpec.describe SpreeCmCommissioner::Cart::AddGuest do
  let(:order) { create(:order) }
  let(:quantity) { 3 }
  let(:line_item) { create(:cm_kyc_line_item, quantity: quantity, order: order) }
  let(:guest) { create(:guest, line_item: line_item) }

  describe '.call' do
    subject { described_class.call(order: order, line_item: line_item) }

    it 'should creates a blank guest then increases quantity when should_increase_quantity? true' do
      allow_any_instance_of(described_class).to receive(:should_increase_quantity?).with(line_item).and_return(true)

      expect_any_instance_of(described_class).to receive(:create_blank_guest).with(line_item).and_call_original
      expect_any_instance_of(described_class).to receive(:increase_quantity).with(line_item).and_call_original

      expect(subject.success?).to be true
      expect(line_item.guests.size).to eq 1
      expect(line_item.quantity).to eq quantity + 1
    end

    it 'should creates a blank guest & does not increases quantity when should_increase_quantity? false' do
      allow_any_instance_of(described_class).to receive(:should_increase_quantity?).with(line_item).and_return(false)

      expect_any_instance_of(described_class).to receive(:create_blank_guest).with(line_item).and_call_original
      expect_any_instance_of(described_class).to_not receive(:increase_quantity)

      expect(subject.success?).to be true
      expect(line_item.guests.size).to eq 1
      expect(line_item.quantity).to eq quantity
    end
  end

  describe '#should_increase_quantity?' do
    subject { described_class.new }

    it 'should return true when total_guests >= required_guests_for_next_unit' do
      allow(subject).to receive(:total_guests).with(line_item).and_return(2)
      allow(subject).to receive(:required_guests_for_next_unit).with(line_item).and_return(2)

      expect(subject.send(:should_increase_quantity?, line_item)).to be true
    end

    it 'should return false when total_guests < required_guests_for_next_unit' do
      allow(subject).to receive(:total_guests).with(line_item).and_return(1)
      allow(subject).to receive(:required_guests_for_next_unit).with(line_item).and_return(2)

      expect(subject.send(:should_increase_quantity?, line_item)).to be false
    end
  end

  describe '#total_guests' do
    subject { described_class.new }

    it 'returns total guests with 1 extra for the new guest' do
      allow(line_item).to receive(:guests).and_return([double(:guest), double(:guest)])
      allow(line_item).to receive(:remaining_total_guests).and_return(3)

      # 2 existing guests + 3 remaining guests + 1 new guest
      total_guests_count = subject.send(:total_guests, line_item)
      expect(total_guests_count).to eq(2 + 3 + 1)
    end
  end

  describe '#required_guests_for_next_unit' do
    subject { described_class.new }

    context 'when line_item has 1 guest per unit' do
      before do
        allow(subject).to receive(:number_of_guests_per_unit).with(line_item).and_return(1)
      end

      it 'return 3 when quantity = 2' do
        allow(line_item).to receive(:quantity).and_return(2)
        expect(subject.send(:required_guests_for_next_unit, line_item)).to eq 3 # 3 x qauntity
      end

      it 'return 4 when quantity = 3' do
        allow(line_item).to receive(:quantity).and_return(3)
        expect(subject.send(:required_guests_for_next_unit, line_item)).to eq 4 # 4 x qauntity
      end
    end

    context 'when line_item has 2 guest per unit' do
      before do
        allow(subject).to receive(:number_of_guests_per_unit).with(line_item).and_return(2)
      end

      it 'return 6 when quantity = 2' do
        allow(line_item).to receive(:quantity).and_return(2)
        expect(subject.send(:required_guests_for_next_unit, line_item)).to eq 6 # 3 x qauntity
      end

      it 'return 8 when quantity = 3' do
        allow(line_item).to receive(:quantity).and_return(3)
        expect(subject.send(:required_guests_for_next_unit, line_item)).to eq 8 # 4 x qauntity
      end
    end
  end

  describe '#number_of_guests_per_unit' do
    subject { described_class.new }

    it 'return number of guest per unit base on variant number_of_guests' do
      allow(line_item.variant).to receive(:number_of_guests).and_return 2

      expect(subject.send(:number_of_guests_per_unit, line_item)).to eq 2
    end
  end
end

