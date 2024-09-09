require 'spec_helper'

RSpec.describe SpreeCmCommissioner::EnsureEventIdForGuestsJob, type: :job do
  include ActiveJob::TestHelper

  after do
    clear_enqueued_jobs
  end

  describe "#perform" do
    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
    let(:section) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A') }
    let(:product) { create(:product, product_type: :ecommerce, taxons: [section]) }
    let(:order) { create(:order, completed_at: Date.current) }
    let(:line_item) { create(:line_item, product: product, order: order) }

    let!(:guest1) { create(:guest, line_item: line_item) }
    let!(:guest2) { create(:guest, line_item: line_item) }

    # set it to null as it auto-assign event_id on save.
    before do
      guest1.update_columns(event_id: nil)
    end

    it "reassign event_id for guests" do
      expect(guest1.reload.event_id).to eq nil
      expect(guest2.reload.event_id).not_to eq nil

      perform_enqueued_jobs { described_class.perform_now }

      expect(guest1.reload.event_id).to eq event.id
      expect(guest2.reload.event_id).to eq event.id
    end
  end
end
