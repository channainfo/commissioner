require 'spec_helper'

RSpec.describe SpreeCmCommissioner::WaitingRoomSessionFirebaseLoggerJob, type: :job do
  describe '#perform' do
    let(:room_session) { SpreeCmCommissioner::WaitingRoomSession.create(guest_identifier: 'guest_identifier', jwt_token: 'jwt_token', expired_at: Date.tomorrow, remote_ip: '168.0.0.1') }
    let(:waiting_guest_firebase_doc_id) { 'firebase_doc_123' }

    let(:options) do
      {
        room_session_id: room_session.id,
        waiting_guest_firebase_doc_id: waiting_guest_firebase_doc_id
      }
    end

    it 'calls WaitingRoomSessionFirebaseLogger with correct arguments' do
      expect(SpreeCmCommissioner::WaitingRoomSessionFirebaseLogger).to receive(:call).with(
        room_session: room_session,
        waiting_guest_firebase_doc_id: waiting_guest_firebase_doc_id
      )

      described_class.perform_now(options)
    end
  end
end
