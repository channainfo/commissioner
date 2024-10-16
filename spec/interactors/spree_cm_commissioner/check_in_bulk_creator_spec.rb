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

    let(:guest_ids) { [
      { guest_id: guest_a.id },
      { guest_id: guest_b.id },
      { guest_id: guest_c.id }
    ] }

    let(:check_ins) do
      [
        {
          guest_id: guest_a.id,
          confirmed_at: DateTime.current,
          guest_attributes: {
            first_name: 'John',
            last_name: 'Doe',
            age: 25,
            gender: 'male',
            phone_number: '0120000001'
          }
        },
        {
          guest_id: guest_b.id,
          confirmed_at: DateTime.current,
          guest_attributes: {
            first_name: 'Jake',
            last_name: 'Rose',
            age: 30,
            gender: 'female',
            phone_number: '0120000002'
          }
        }
      ]
    end

    it 'creates check_ins and update guest info' do
      context = described_class.call(check_ins_attributes: check_ins)

      expect(context.success?).to be true
      expect(context.check_ins.size).to eq(check_ins.size)

      expect(guest_a.reload.full_name).to eq 'John Doe'
      expect(guest_a.reload.age).to eq 25
      expect(guest_a.reload.gender).to eq 'male'
      expect(guest_a.reload.phone_number).to eq '0120000001'

      expect(guest_b.reload.full_name).to eq 'Jake Rose'
      expect(guest_b.reload.age).to eq 30
      expect(guest_b.reload.gender).to eq 'female'
      expect(guest_b.reload.phone_number).to eq '0120000002'
    end

    it 'should creates check_ins for each guest' do
      context = described_class.call(check_ins_attributes: guest_ids)

      expect(context.success?).to be true
      expect(context.check_ins.size).to eq (guest_ids.size)
    end

    it 'creates multiple check_ins for multiple guests' do
      multiple_guest_ids = [
        { guest_id: guest_a.id },
        { guest_id: guest_b.id },
        { guest_id: guest_c.id }
      ]
      context = described_class.call(check_ins_attributes: multiple_guest_ids)

      expect(context.success?).to be true
      expect(context.check_ins.size).to eq(3)
    end

    it 'does not create check_ins for invalid guest ids' do
      invalid_guest_id = [
        { guest_id: 9999 }
      ]

      context = described_class.call(check_ins_attributes: invalid_guest_id)

      expect(context.success?).to be false
      expect(context.check_ins).to be_nil
    end

    it 'does not create if one of guest invalid' do
      invalid_guest_id = 9999
      guest_ids = [
        { guest_id: guest_a.id },
        { guest_id: guest_b.id },
        { guest_id: invalid_guest_id }
      ]

      context = described_class.call(check_ins_attributes: guest_ids)

      expect(context.message).to eq :guest_not_found
      expect(context.success?).to be false
      expect(context.check_ins).to be_nil
    end
  end
end
