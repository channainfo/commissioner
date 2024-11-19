require 'spec_helper'

RSpec.describe SpreeCmCommissioner::WaitingRoomSessionCreator do
  describe '.call', :vcr do
    it 'generate jwt token, record session to db & log it in user firebase document' do
      ENV['WAITING_ROOM_SESSION_SIGNATURE'] = '4234f0a3-c42f-40b5-9057-7c006793cea4'
      allow_any_instance_of(described_class).to receive(:log_to_firebase)
      allow_any_instance_of(described_class).to receive(:full?).and_return(false)

      context = described_class.call(remote_ip: '43.230.192.190', waiting_guest_firebase_doc_id: 'FYFFEj0O4QSpipNsHzRh')
      expect(context.room_session.jwt_token.present?).to be true
      expect(context.room_session.jwt_token).to eq context.jwt_token
    end
  end
end
