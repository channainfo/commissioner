require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ProductEventIdToChildrenSyncer do
  describe '.call' do
    let!(:taxonomy) { create(:taxonomy, kind: :event) }
    let!(:event1) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy, kind: :event, from_date: '2001-01-01'.to_date, to_date: '2001-01-02'.to_date) }
    let!(:event1_section) { create(:taxon, parent: event1, taxonomy: taxonomy, name: 'Section A') }

    let!(:event2) { create(:taxon, name: 'RunWithSai', taxonomy: taxonomy, kind: :event, from_date: '2001-01-01'.to_date, to_date: '2001-01-02'.to_date) }
    let!(:event2_section) { create(:taxon, parent: event2, taxonomy: taxonomy, name: 'Section A') }

    let!(:product) { create(:product, taxons: [event1_section]) }

    let!(:variant1) { create(:cm_variant, product: product) }
    let!(:variant2) { create(:cm_variant, product: product) }

    let!(:line_item1) { create(:line_item, variant: variant1) }
    let!(:line_item2) { create(:line_item, variant: variant2) }

    let!(:guest1) { create(:guest, line_item: line_item1) }
    let!(:guest2) { create(:guest, line_item: line_item2) }

    before do
      # make sure data correct
      expect(line_item1.event_id).to eq event1.id
      expect(line_item2.event_id).to eq event1.id

      expect(product.event_id).to eq event1.id

      expect(guest1.event_id).to eq event1.id
      expect(guest2.event_id).to eq event1.id

      # avoid it taxon to run callback, which will trigger this class.
      # we want to trigger them manually in this instead.
      allow(product).to receive(:sync_event_id_to_children).and_return(true)
    end

    it 'update line item, guest to new event_id' do
      product.update!(taxons: [event2_section])
      described_class.call(product: product.reload)

      expect(line_item1.reload.event_id).to eq event2.id
      expect(line_item2.reload.event_id).to eq event2.id

      expect(product.reload.event_id).to eq event2.id

      expect(guest1.reload.event_id).to eq event2.id
      expect(guest2.reload.event_id).to eq event2.id
    end
  end
end
