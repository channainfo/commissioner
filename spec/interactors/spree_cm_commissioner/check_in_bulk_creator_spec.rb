require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CheckInBulkCreator do
  describe '#call' do
    let(:guest_a) { create(:guest, first_name: 'Guest A', last_name: 'B') }
    let(:guest_b) { create(:guest, first_name: 'Guest B', last_name: 'A') }
    let(:guest_c) { create(:guest, first_name: 'Guest C', last_name: 'C') }

    let(:guest_ids) { [guest_a.id, guest_b.id, guest_c.id] }

    it 'creates check_ins for each guest' do
      context = described_class.call(guest_ids: guest_ids)

      expect(context.success?).to be true
      expect(context.check_ins.size).to eq (guest_ids.size)
    end

    it 'creates multiple check_ins for multiple guests' do
      multiple_guest_ids = [guest_a.id, guest_b.id, guest_c.id]

      context = described_class.call(guest_ids: multiple_guest_ids)

      expect(context.success?).to be true
      expect(context.check_ins.size).to eq(3)
    end

    it 'does not create check_ins for invalid guest ids' do
      invalid_guest_id = [9999]

      context = described_class.call(guest_ids: invalid_guest_id)

      expect(context.success?).to be false
      expect(context.check_ins).to be_nil
    end

    it 'does not create if one of guest invalid' do
      invalid_guest_id = 9999
      guest_ids = [guest_a.id, guest_b.id, invalid_guest_id]

      context = described_class.call(guest_ids: guest_ids)

      expect(context.message).to eq :guest_not_found
      expect(context.success?).to be false
      expect(context.check_ins).to be_nil
    end

  end
end
