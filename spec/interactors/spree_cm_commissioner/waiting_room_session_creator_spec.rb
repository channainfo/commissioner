require 'spec_helper'

RSpec.describe SpreeCmCommissioner::WaitingRoomSessionCreator do
  describe '.call', :vcr do
    it 'generate jwt token, record session to db & log it in user firebase document' do
      ENV['WAITING_ROOM_SESSION_SIGNATURE'] = '4234f0a3-c42f-40b5-9057-7c006793cea4'
      allow_any_instance_of(described_class).to receive(:log_to_firebase)
      allow_any_instance_of(described_class).to receive(:full?).and_return(false)

      # https://github.com/channainfo/commissioner/issues/2185
      expect_any_instance_of(described_class).not_to receive(:call_other_waiting_guests)
      expect(SpreeCmCommissioner::WaitingGuestsCallerJob).not_to receive(:perform_later)

      context = described_class.call(remote_ip: '43.230.192.190', waiting_guest_firebase_doc_id: 'FYFFEj0O4QSpipNsHzRh', page_path: '/tickets/sai')
      expect(context.room_session.jwt_token.present?).to be true
      expect(context.room_session.jwt_token).to eq context.jwt_token
      expect(context.room_session.page_path).to eq '/tickets/sai'
    end
  end
end
