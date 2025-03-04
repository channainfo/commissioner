require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderBibNumberConcern do
  let(:taxonomy) { create(:taxonomy, kind: :event) }
  let(:event1) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
  let(:product_with_bib1) { create(:cm_bib_number_product, product_type: :ecommerce, taxons: [event1]) }
  let(:order) { create(:order, completed_at: nil) }

  let(:line_item) { create(:line_item, order: order, variant: product_with_bib1.variants.first) }
  let(:line_items) { [line_item] }
  let(:guest) { create(:guest, line_item: line_item, seat_number: 1) }
  let(:guests) { [guest] }

  describe 'callbacks' do
    it 'calls generate_guests_and_bib_numbers after update if state is complete' do
      expect(order).to receive(:generate_guests_and_bib_numbers)
      order.update(state: 'complete')
    end
  end

  describe '#generate_guests_and_bib_numbers' do
    it 'calls generate_remaining_guests' do
      expect(order).to receive(:generate_remaining_guests)
      order.send(:generate_guests_and_bib_numbers)
    end

    it 'calls generate_bib_number_aysnc' do
      expect(order).to receive(:generate_bib_number_aysnc)
      order.send(:generate_guests_and_bib_numbers)
    end
  end

  describe "#generate_remaining_guests" do
    it 'calls generate_remaining_guests for each line item' do
      allow(order).to receive(:line_items).and_return(line_items)
      allow(line_items).to receive(:find_each).and_yield(line_item)

      expect(line_item).to receive(:generate_remaining_guests).once
      order.send(:generate_remaining_guests)
    end
  end

  describe "#generate_bib_number_aysnc" do
    it "enque a job with SpreeCmCommissioner::OrderCompleteBibGeneratorJob" do
      expect {
        order.send(:generate_bib_number_aysnc)
      }.to have_enqueued_job(SpreeCmCommissioner::OrderCompleteBibGeneratorJob).with(order.id)
    end
  end

  describe "#generate_bib_number!" do
    it 'calls generate_bib! for each guest with none_bib' do
      allow(order).to receive(:line_items).and_return(line_items)
      allow(line_items).to receive(:with_bib_prefix).and_return(line_items)
      allow(line_items).to receive(:find_each).and_yield(line_item)
      allow(line_item).to receive_message_chain(:guests, :none_bib).and_return(guests)
      allow(guests).to receive(:find_each).and_yield(guest)

      expect(guest).to receive(:generate_bib!).once
      order.generate_bib_number!
    end
  end
end
