require 'spec_helper'

RSpec.describe SpreeCmCommissioner::EventQrGenerator do
  let(:operator) { create(:user) }
  let(:event) { create(:taxon, kind: :event) }

  subject { described_class.call(operator: operator, event: event, expired_in_mn: 60) }

  describe '#call' do
    it 'set event_qr to context with correct datas' do
      expect(subject.event_qr.id).to eq(operator.id)
      expect(subject.event_qr.qr_data).to be_present
      expect(subject.event_qr.expired_at).to be_present
    end
  end
end
