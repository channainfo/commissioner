require 'spec_helper'

RSpec.describe Spree::State, type: :model do
  include ActiveJob::TestHelper

  describe 'callbacks' do
    let(:state) { create(:state, total_inventory: 0) }
    let(:vendor) { create(:cm_vendor, state_id: state.id, total_inventory: 0) }

    it 'updates state when vendor total_inventory are changed' do
      perform_enqueued_jobs do
        vendor.update(total_inventory: 4)
        state.reload

        expect(state.total_inventory).to eq 4
      end
    end
  end
end
