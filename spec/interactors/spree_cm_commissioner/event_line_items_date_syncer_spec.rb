require 'spec_helper'

RSpec.describe SpreeCmCommissioner::EventLineItemsDateSyncer do
  describe '.call' do
    let!(:taxonomy) { create(:taxonomy, kind: :event) }
    let!(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy, kind: :event, from_date: '2001-01-01'.to_date, to_date: '2001-01-02'.to_date) }
    let!(:section) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A', kind: :event) }


    context 'when variant does not has :start_date_time' do
      let!(:product) { create(:product, taxons: [section]) }
      let!(:variant) { create(:cm_variant, product: product) }
      let!(:line_item) { create(:line_item, variant: variant) }

      before do
        # make sure data correct
        expect(line_item.from_date).to eq '2001-01-01'.to_date
        expect(line_item.to_date).to eq '2001-01-02'.to_date
        expect(line_item.event_id).to eq event.id

        # avoid it taxon to run callback, which will trigger this class.
        # we want to trigger them manually in this instead.
        allow(event).to receive(:sync_event_line_item_dates).and_return(true)
      end

      it 'update previous line item to new event date' do
        event.update!(from_date: '2050-01-01'.to_date, to_date: '2050-01-02'.to_date)
        described_class.call(event: event.reload)

        expect(line_item.reload.from_date).to eq '2050-01-01'.to_date
        expect(line_item.reload.to_date).to eq '2050-01-02'.to_date
      end
    end

    context 'when variant has :start_date_time' do
      let(:start_date) { create(:cm_option_type, :start_date) }
      let(:start_date_value) { create(:cm_option_value, name: '2020-01-01', option_type: start_date) }

      let(:end_date) { create(:cm_option_type, :end_date) }
      let(:end_date_value) { create(:cm_option_value, name: '2020-01-05', option_type: end_date) }

      let!(:product) { create(:product, taxons: [section], option_types: [start_date, end_date]) }
      let!(:variant) { create(:cm_variant, product: product, option_values: [start_date_value, end_date_value]) }
      let!(:line_item) { create(:line_item, variant: variant) }

      before do
        # make sure data correct
        expect(line_item.from_date).to eq '2020-01-01'.to_date
        expect(line_item.to_date).to eq '2020-01-05'.to_date
        expect(line_item.event_id).to eq event.id

        # avoid it taxon to run callback, which will trigger this class.
        # we want to trigger them manually in this instead.
        allow(event).to receive(:sync_event_line_item_dates).and_return(true)
      end

      it 'keep variant date instead of using new date' do
        event.update!(from_date: '2050-01-01'.to_date, to_date: '2050-01-02'.to_date)
        described_class.call(event: event.reload)

        expect(line_item.reload.from_date).to eq '2020-01-01'.to_date
        expect(line_item.reload.to_date).to eq '2020-01-05'.to_date
      end
    end
  end
end
