require "spec_helper"

RSpec.describe SpreeCmCommissioner::Cart::RemoveGuest do
  let(:order) { create(:order) }
  let(:quantity) { 3 }
  let(:line_item) { create(:cm_kyc_line_item, quantity: quantity, order: order) }
  let(:guest) { create(:guest, line_item: line_item) }

  describe '.call' do
    context 'when guest_id is provided' do
      subject { described_class.call(order: order, line_item: line_item, guest_id: guest.id) }

      it 'should removes guest then decreases quantity when should_decrease_quantity? true' do
        allow_any_instance_of(described_class).to receive(:should_decrease_quantity?).with(line_item).and_return(true)

        expect_any_instance_of(described_class).to receive(:remove_guest).with(order, line_item, guest.id).and_call_original
        expect_any_instance_of(described_class).to receive(:decrease_quantity).with(order, line_item).and_call_original

        expect(subject.success?).to be true
        expect(SpreeCmCommissioner::Guest.exists?(guest.id)).to be false
        expect(line_item.quantity).to eq quantity - 1
      end

      it 'should removes guest & does not decreases quantity when should_decrease_quantity? false' do
        allow_any_instance_of(described_class).to receive(:should_decrease_quantity?).with(line_item).and_return(false)

        expect_any_instance_of(described_class).to receive(:remove_guest).with(order, line_item, guest.id).and_call_original
        expect_any_instance_of(described_class).to_not receive(:decrease_quantity)

        expect(subject.success?).to be true
        expect(SpreeCmCommissioner::Guest.exists?(guest.id)).to be false
        expect(line_item.quantity).to eq quantity
      end
    end

    context 'when guest_id is blank (does not call remove_guest)' do
      subject { described_class.call(order: order, line_item: line_item, guest_id: nil) }

      it 'should decrease quantity when should_decrease_quantity? true' do
        allow_any_instance_of(described_class).to receive(:should_decrease_quantity?).with(line_item).and_return(true)

        expect_any_instance_of(described_class).to_not receive(:remove_guest)
        expect_any_instance_of(described_class).to receive(:decrease_quantity).with(order, line_item).and_call_original

        expect(subject.success?).to be true
        expect(line_item.quantity).to eq quantity - 1
      end

      # in this case, the class does not do anything except recaculate cart.
      it 'does not decrease quantity when should_decrease_quantity? false' do
        allow_any_instance_of(described_class).to receive(:should_decrease_quantity?).with(line_item).and_return(false)

        expect_any_instance_of(described_class).to_not receive(:remove_guest)
        expect_any_instance_of(described_class).to_not receive(:decrease_quantity)

        expect(subject.success?).to be true
        expect(line_item.quantity).to eq quantity
      end
    end
  end

  describe '#should_decrease_quantity?' do
    subject { described_class.new }

    it 'should return true when total_guests <= required_guests_for_next_unit' do
      allow(subject).to receive(:total_guests).with(line_item).and_return(2)
      allow(subject).to receive(:required_guests_for_next_unit).with(line_item).and_return(2)

      expect(subject.send(:should_decrease_quantity?, line_item)).to be true
    end

    it 'should return false when total_guests > required_guests_for_next_unit' do
      allow(subject).to receive(:total_guests).with(line_item).and_return(3)
      allow(subject).to receive(:required_guests_for_next_unit).with(line_item).and_return(2)

      expect(subject.send(:should_decrease_quantity?, line_item)).to be false
    end
  end

  describe '#total_guests' do
    subject { described_class.new }

    it 'returns total guests base on guests size' do
      allow(line_item).to receive(:guests).and_return([double(:guest), double(:guest)])

      expect(subject.send(:total_guests, line_item)).to eq 2
      expect(line_item.guests.size).to eq 2
    end
  end

  describe '#required_guests_for_previous_unit' do
    subject { described_class.new }

    context 'when line_item has 1 guest per unit' do
      before do
        allow(subject).to receive(:number_of_guests_per_unit).with(line_item).and_return(1)
      end

      it 'return 1 when quantity = 2' do
        allow(line_item).to receive(:quantity).and_return(2)
        expect(subject.send(:required_guests_for_previous_unit, line_item)).to eq 1
      end

      it 'return 2 when quantity = 3' do
        allow(line_item).to receive(:quantity).and_return(3)
        expect(subject.send(:required_guests_for_previous_unit, line_item)).to eq 2
      end
    end

    context 'when line_item has 2 guest per unit' do
      before do
        allow(subject).to receive(:number_of_guests_per_unit).with(line_item).and_return(2)
      end

      it 'return 2 when quantity = 2' do
        allow(line_item).to receive(:quantity).and_return(2)
        expect(subject.send(:required_guests_for_previous_unit, line_item)).to eq 2
      end

      it 'return 4 when quantity = 3' do
        allow(line_item).to receive(:quantity).and_return(3)
        expect(subject.send(:required_guests_for_previous_unit, line_item)).to eq 4
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
