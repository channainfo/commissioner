require 'spec_helper'

RSpec.describe SpreeCmCommissioner::WaitingRoomSessionFirebaseLogger do
  let(:mock_firestore) { instance_double(Google::Cloud::Firestore::Client) }
  let(:mock_doc_ref)   { instance_double(Google::Cloud::Firestore::DocumentReference) }
  let(:mock_col_ref)   { instance_double(Google::Cloud::Firestore::CollectionReference) }
  let(:mock_doc_snap)  { instance_double(Google::Cloud::Firestore::DocumentSnapshot) }

  let(:waiting_guest_firebase_doc_id) { 'L0y4wEEKowOI4eWqAW3f' }

  let(:room_session) do
    SpreeCmCommissioner::WaitingRoomSession.create!(
      guest_identifier: 'guest_identifier',
      jwt_token: 'jwt_token',
      created_at: Time.zone.parse('2025-05-22T10:00:00Z'),
      updated_at: '2025-05-22'.to_date,
      expired_at: Date.tomorrow,
      remote_ip: '168.0.0.1',
      page_path: '/some/path'
    )
  end

  before do
    allow_any_instance_of(described_class).to receive(:service_account).and_return({ project_id: 'your-mocked-project-id' })
    allow(Google::Cloud::Firestore).to receive(:new).and_return(mock_firestore)

    # Firestore doc chain: firestore.col(...).doc(...).col(...).doc(...)
    allow(mock_firestore).to receive(:col).with('waiting_guests').and_return(mock_col_ref)
    allow(mock_col_ref).to receive(:doc).with('2025-05-22').and_return(mock_doc_ref)

    allow(mock_doc_ref).to receive(:col).with('records').and_return(mock_col_ref)
    allow(mock_col_ref).to receive(:doc).with(waiting_guest_firebase_doc_id).and_return(mock_doc_ref)

    # Simulate getting existing Firestore data
    allow(mock_doc_ref).to receive(:get).and_return(mock_doc_snap)
    allow(mock_doc_snap).to receive(:data).and_return({ name: 'Guest' })

    # Expect update to be called with added `entered_room_at` and `page_path`
    allow(mock_doc_ref).to receive(:update)
  end

  it 'logs session info into Firestore' do
    expect(mock_doc_ref).to receive(:update).with(
      hash_including(
        name: 'Guest',
        entered_room_at: room_session.created_at,
        page_path: room_session.page_path
      )
    )

    described_class.call(
      room_session: room_session,
      waiting_guest_firebase_doc_id: waiting_guest_firebase_doc_id,
    )
  end
end
