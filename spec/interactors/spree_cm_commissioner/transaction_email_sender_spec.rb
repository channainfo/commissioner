require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TransactionalEmailSender, type: :interactor do

  let(:png) { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.png'), 'image/*') }
  let!(:home_banner) { create(:cm_taxon_home_banner, attachment: png) }

  let(:taxonomy) { create(:taxonomy, kind: :event) }
  let(:event) { create(:taxon, taxonomy: taxonomy ,home_banner: home_banner) }
  let(:user) { create(:user) }

  context 'when no home_banner is attached to event' do
    before do
      event.update(home_banner: nil)
    end

    it 'fails with message' do
      result = described_class.call(event_id: event.id, recipient_id: user.id, type: 'organizer')
      expect(result).to be_a_failure
      expect(result.message).to eq('Banner Image required')
    end
  end

  context 'when email was already sent' do
    before do
      create(:cm_transactional_email, taxon_id: event.id, recipient_id: user.id, recipient_type: 'Spree::User', sent_at: Time.current)
    end

    it 'fails with message' do
      result = described_class.call(event_id: event.id, recipient_id: user.id, type: 'organizer')
      expect(result).to be_a_failure
      expect(result.message).to eq('Email already sent')
    end
  end

  context 'when email has not been sent' do
    let!(:email) do
      create(:cm_transactional_email, taxon_id: event.id, recipient_id: user.id, recipient_type: 'Spree::User', sent_at: nil)
    end

    it 'updates sent_at' do
      freeze_time do
        result = described_class.call(event_id: event.id, recipient_id: user.id, type: 'organizer')
        expect(result).to be_a_success
        expect(email.reload.sent_at).to eq(Time.current)
      end
    end

    it 'sends email to organizer if type is organizer' do
      expect(SpreeCmCommissioner::EventTransactionalMailer)
        .to receive(:send_to_organizer).with(event.id, user.id).and_return(double(deliver_later: true))

      described_class.call(event_id: event.id, recipient_id: user.id, type: 'organizer')
    end

    it 'sends email to participant if type is participant' do
      expect(SpreeCmCommissioner::EventTransactionalMailer)
        .to receive(:send_to_participant).with(event.id, user.id).and_return(double(deliver_later: true))

      described_class.call(event_id: event.id, recipient_id: user.id, type: 'participant')
    end
  end
end
