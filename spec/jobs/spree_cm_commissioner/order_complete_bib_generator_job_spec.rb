require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderCompleteBibGeneratorJob, type: :job do
  let(:order) { create(:order) }
  let(:order_id) { order.id }

  describe '#perform' do
    it 'finds the order by id' do
      expect(Spree::Order).to receive(:find).with(order_id).and_return(order)
      subject.perform(order_id)
    end

    it 'generates guest BIB for the order' do
      allow(Spree::Order).to receive(:find).with(order_id).and_return(order)

      expect(order).to receive(:generate_bib_number!)
      subject.perform(order_id)
    end
  end
end
