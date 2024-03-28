require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CheckInDestroyer do
  describe '#call' do
    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
    let(:section_a) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A') }
    let(:product_a) { create(:product, product_type: :ecommerce, taxons: [section_a]) }
    let(:line_item_a) { create(:line_item, product: product_a) }
    let(:guest_a) { create(:guest, first_name: 'Guest A', last_name: 'A', line_item: line_item_a) }

    it 'destroys check_in for a specific guest' do
      # Stub any necessary method calls or objects
      allow(SpreeCmCommissioner::Guest).to receive(:where).with(id: [guest_a.id]).and_return([guest_a])
      allow(guest_a).to receive_message_chain(:check_in, :destroy).and_return(true)

      context = described_class.call(guest_ids: [guest_a.id])

      expect(context.success?).to be true
      expect(context.check_ins.size).to eq(1)
    end

    it 'fails if guest_id is blank' do
      context = described_class.call(guest_ids: [])

      expect(context.success?).to be false
      expect(context.message).to eq(:guest_ids_must_not_blank)
      expect(context.check_ins).to be_nil
    end

    it 'fails if guest_id is not found' do
      context = described_class.call(guest_ids: [9999])

      expect(context.success?).to be false
      expect(context.message).to eq(:guest_not_found)
      expect(context.check_ins).to be_nil
    end
  end
end
