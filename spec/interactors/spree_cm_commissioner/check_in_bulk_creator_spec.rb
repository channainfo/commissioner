require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CheckInBulkCreator do
  describe '#call' do
    # guest.line_item.product.taxons.where(kind: :event).first.parent
    let(:taxonomy) { create(:taxonomy, kind: :event) }

    let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }

    let(:section_a) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A') }
    let(:section_b) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section B') }

    let(:product_a) { create(:product, product_type: :ecommerce, taxons: [section_a]) }
    let(:product_b) { create(:product, product_type: :ecommerce, taxons: [section_b]) }

    let(:line_item_a) { create(:line_item, product: product_a) }
    let(:line_item_b) { create(:line_item, product: product_b) }

    let(:guest_a) { create(:guest, first_name: 'Guest A', last_name: 'A', line_item: line_item_a)}
    let(:guest_b) { create(:guest, first_name: 'Guest B', last_name: 'B', line_item: line_item_b)}
    let(:guest_c) { create(:guest, first_name: 'Guest C', last_name: 'C', line_item: line_item_a)}

    let(:guest_ids) { [guest_a.id, guest_b.id, guest_c.id] }

    it 'should creates check_ins for each guest' do
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
