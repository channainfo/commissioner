require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ConversionPreCalculator do
  let(:taxonomy) { create(:taxonomy, kind: :event) }
  let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
  let(:section) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A') }

  let(:product) { create(:product, product_type: :ecommerce) }
  let(:guest) { create(:guest, first_name: 'Ean', last_name: 'Eii', event_id: nil) }

  let!(:line_item) { create(:line_item, product: product, guests: [guest]) }

  let(:product_section) { create(:cm_product_taxon, product: product, taxon: section) }

  describe '.call' do
    it 'reassign guest event_id & update update_conversion' do
      expect_any_instance_of(described_class).to receive(:reassign_guests_event_id)
      expect_any_instance_of(described_class).to receive(:update_conversion)

      described_class.call(product_taxon: product_section)
    end
  end

  describe '#reassign_guests_event_id' do
    subject { described_class.new(product_taxon: product_section) }

    context 'when section kind is :event' do
      context 'when section has parent' do
        it 'update event_id for guest' do
          expect(guest.reload.event_id).to eq nil

          subject.reassign_guests_event_id

          expect(guest.reload.event_id).to eq event.id
        end
      end

      context 'when section has not parent' do
        it 'does not update event_id to guest' do
          section.update(parent_id: nil)

          subject.reassign_guests_event_id

          expect(guest.reload.event_id).to eq nil
        end
      end
    end

    context 'when section kind is not :event' do
      let(:taxonomy) { create(:taxonomy, kind: :cms) }

      it 'does not update event_id to guest' do
        subject.reassign_guests_event_id
        expect(guest.reload.event_id).to eq nil
      end
    end
  end
end
