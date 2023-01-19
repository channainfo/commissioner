require 'spec_helper'

RSpec.describe SpreeCmCommissioner::StateUpdater do
  describe '.call' do
    let(:state) {create(:state, total_inventory: 0)}
    let!(:angkor_hotel) { create(:cm_vendor, name: 'Angkor Hotel', state_id: state.id, total_inventory: 3) }
    let!(:sokha_pp_hotel) { create(:cm_vendor, name: 'Sokha Phnom Penh Hotel', state_id: state.id, total_inventory: 2) }

    it 'update state total inventory' do
      context = SpreeCmCommissioner::StateUpdater.call(state: state)
      state.reload

      expect(state.total_inventory).to eq 5
    end
  end
end
