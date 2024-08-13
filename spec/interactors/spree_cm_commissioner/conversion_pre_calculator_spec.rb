require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ConversionPreCalculator do
  let(:taxonomy) { create(:taxonomy, kind: :event) }
  let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
  let(:section) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A') }

  let(:product) { create(:product, product_type: :ecommerce) }
  let(:guest) { create(:guest, first_name: 'Ean', last_name: 'Eii', event_id: nil) }

  let(:product_section) { create(:cm_product_taxon, product: product, taxon: section) }

  describe '.call' do
    it 'reassign guest event_id & update update_conversion' do
      expect_any_instance_of(described_class).to receive(:reassign_guests_event_id)
      expect_any_instance_of(described_class).to receive(:update_conversion)

      described_class.call(product_taxon: product_section)
    end
  end

  describe '#event_id' do
    context 'when section is not event' do
      let(:taxonomy) { create(:taxonomy, kind: :cms) }
      let(:taxon) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
      let(:section) { create(:taxon, parent: taxon, taxonomy: taxonomy, name: 'Section A') }

      subject { described_class.new(product_taxon: product_section) }

      it 'return nil' do
        expect(section&.event?).to be false
        expect(subject.event_id).to eq nil
      end
    end

    context 'when section is event' do
      let(:taxonomy) { create(:taxonomy, kind: :event) }
      let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
      let(:section) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A') }

      subject { described_class.new(product_taxon: product_section) }

      it 'return parent of section as event' do
        expect(section.event?).to be true
        expect(section.parent).to eq event

        expect(subject.event_id).to eq event.id
      end
    end
  end

  describe '#reassign_guests_event_id' do
    let!(:line_item) { create(:line_item, product: product, guests: [guest]) }

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

  describe '#generate_guests_bib_number' do
    context 'when event_id is present' do
      let(:taxonomy) { create(:taxonomy, kind: :event) }
      let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
      let!(:section1) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A', products: [product_without_bib, product_with_5km_bib, product_with_7km_bib]) }
      let!(:section2) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section B', products: [product_with_5km_bib_from_different_section]) }

      let(:bib_prefix) { create(:cm_option_type, :bib_prefix) }
      let(:bib_prefix_5km) { create(:cm_option_value, name: '5KM', option_type: bib_prefix) }
      let(:bib_prefix_7km) { create(:cm_option_value, name: '7KM', option_type: bib_prefix) }

      let(:product_without_bib) { create(:product, option_types: []) }
      let(:product_with_5km_bib) { create(:product, option_types: [bib_prefix]) }
      let(:product_with_7km_bib) { create(:product, option_types: [bib_prefix]) }
      let(:product_with_5km_bib_from_different_section) { create(:product, option_types: [bib_prefix]) }

      let(:variant_without_bib) { create(:variant, product: product_without_bib) }
      let(:variant_with_5km_bib) { create(:variant, option_values: [bib_prefix_5km], product: product_with_5km_bib) }
      let(:variant_with_7km_bib) { create(:variant, option_values: [bib_prefix_7km], product: product_with_7km_bib) }
      let(:variant_with_5km_bib_from_different_section) { create(:variant, option_values: [bib_prefix_5km], product: product_with_5km_bib_from_different_section) }

      let(:line_item1) { create(:line_item, variant: variant_without_bib, order: order) }
      let(:line_item2) { create(:line_item, variant: variant_with_5km_bib, order: order) }
      let(:line_item3) { create(:line_item, variant: variant_with_7km_bib, order: order) }
      let(:line_item4) { create(:line_item, variant: variant_with_5km_bib_from_different_section, order: order) }

      let!(:order) { create(:order, completed_at: Date.current) }

      let!(:guest1) { create(:guest, first_name: 'Ean', last_name: 'Eii', line_item: line_item1) }
      let!(:guest2) { create(:guest, first_name: 'Ean', last_name: 'Eii', line_item: line_item2) }
      let!(:guest3) { create(:guest, first_name: 'Ean', last_name: 'Eii', line_item: line_item3) }
      let!(:guest4) { create(:guest, first_name: 'Ean', last_name: 'Eii', line_item: line_item4) }

      subject { described_class.new(product_taxon: section1.classifications.first) }

      # more details how it generated check guest_spec.rb #generate_bib
      it 'generate bib number for all guests in event' do
        expect(guest1.reload.formatted_bib_number).to eq nil
        expect(guest2.reload.formatted_bib_number).to eq nil
        expect(guest3.reload.formatted_bib_number).to eq nil
        expect(guest4.reload.formatted_bib_number).to eq nil

        subject.generate_guests_bib_number

        expect(guest1.reload.formatted_bib_number).to eq nil
        expect(guest2.reload.formatted_bib_number).to eq '5KM001'
        expect(guest3.reload.formatted_bib_number).to eq '7KM001'
        expect(guest4.reload.formatted_bib_number).to eq '5KM002'
      end
    end
  end
end
