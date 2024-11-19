require 'spec_helper'

RSpec.describe SpreeCmCommissioner::WaitingGuestsCaller do
  describe '.call' do
    it 'fetch available slots, get longest waiting guests, invite those guests & mark to firebase as not full' do
      expect_any_instance_of(described_class).to receive(:fetch_available_slots).and_return(3)
      expect_any_instance_of(described_class).to receive(:fetch_long_waiting_guests).with(3).and_return(['guest1', 'guest2'])
      expect_any_instance_of(described_class).to receive(:calling_all).with(['guest1', 'guest2'])
      expect_any_instance_of(described_class).to receive(:mark_as).with(full: false, available_slots: 3 - 2)

      described_class.call
    end

    it 'did not continue when available slots <= 0' do
      expect_any_instance_of(described_class).to receive(:fetch_available_slots).and_return(0)
      expect_any_instance_of(described_class).not_to receive(:fetch_long_waiting_guests)
      expect_any_instance_of(described_class).not_to receive(:calling_all)

      described_class.call
    end

    it 'mark to firebase full when waiting guests >= available_slot' do
      expect_any_instance_of(described_class).to receive(:fetch_available_slots).and_return(3)
      expect_any_instance_of(described_class).to receive(:fetch_long_waiting_guests).with(3).and_return(['guest1', 'guest2', 'guest3'])
      expect_any_instance_of(described_class).to receive(:calling_all).with(['guest1', 'guest2', 'guest3'])

      expect_any_instance_of(described_class).to receive(:mark_as).with(full: true, available_slots: 3 - 3)

      described_class.call
    end

    it 'mark to firebase not full when waiting guests < available_slot' do
      expect_any_instance_of(described_class).to receive(:fetch_available_slots).and_return(3)
      expect_any_instance_of(described_class).to receive(:fetch_long_waiting_guests).with(3).and_return(['guest1', 'guest2'])
      expect_any_instance_of(described_class).to receive(:calling_all).with(['guest1', 'guest2'])

      expect_any_instance_of(described_class).to receive(:mark_as).with(full: false, available_slots: 3 - 2)

      described_class.call
    end
  end
end
