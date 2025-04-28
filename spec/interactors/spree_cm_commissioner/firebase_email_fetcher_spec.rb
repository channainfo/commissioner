require 'spec_helper'

RSpec.describe SpreeCmCommissioner::FirebaseEmailFetcher, type: :interactor do
  let(:user_id) { '777' }
  let(:sub) { '734348432' }
  let(:email) { 'test@example.com' }

  let(:firebase_user) do
    double('FirebaseUser', provider_data: [double(email: email)])
  end

  let(:firebase_manager) do
    double('Firebase::Admin::Auth::UserManager', get_user_by: firebase_user)
  end

  let(:service_account) { { project_id: 'bookmeplus' } }

  before do
    allow(Firebase::Admin::Auth::UserManager).to receive(:new).and_return(firebase_manager)
    allow_any_instance_of(SpreeCmCommissioner::FirebaseEmailFetcher).to receive(:initialize_firebase_manager).and_return(firebase_manager)
    allow(Rails.application.credentials).to receive(:cloud_firestore_service_account).and_return(service_account)
  end

  describe '#call' do
    context 'when user_id is provided' do
      before do
        allow(firebase_manager).to receive(:get_user_by).with(uid: user_id).and_return(firebase_user)
      end

      it 'fetches the email from Firebase using user_id' do
        context = described_class.call(user_id: user_id)

        expect(context.email).to eq(email)
      end
    end

    context 'when sub is provided' do
      before do
        allow(firebase_manager).to receive(:get_user_by_sub).with(sub: sub).and_return(firebase_user)
      end

      it 'fetches the email from Firebase using sub' do
        context = described_class.call(sub: sub)

        expect(context.email).to eq(email)
      end
    end
  end
end
