require 'spec_helper'

RSpec.describe SpreeCmCommissioner::GuestUpdater, type: :interactor do
  let(:guest) { create(:guest, template_guest: template_guest) }
  let(:template_guest) { create(:template_guest) }
  let(:guest_params) { { first_name: 'Sokleng', last_name: 'Houng' } }
  let(:template_guest_id) { template_guest.id }

  subject { described_class.call(guest: guest, guest_params: guest_params, template_guest_id: template_guest_id) }

  context 'when template_guest_id is provided' do
    before do
      allow(SpreeCmCommissioner::TemplateGuest).to receive(:find).with(template_guest_id).and_return(template_guest)
      allow(guest).to receive(:update).and_return(true)
      allow(SpreeCmCommissioner::IdCardDuplicator).to receive(:call).and_return(double(success?: true))
    end

    it 'updates the guest with template guest attributes' do
      expect(guest).to receive(:update).with(template_guest.attributes.except('id', 'created_at', 'updated_at', 'is_default', 'deleted_at'))
      subject
    end

    it 'duplicates the id card if template guest has one' do
      allow(template_guest).to receive(:id_card).and_return(double(:id_card))
      expect(SpreeCmCommissioner::IdCardDuplicator).to receive(:call).with(guest: guest, template_guest: template_guest)
      subject
    end

    it 'fails if guest update fails' do
      allow(guest).to receive(:update).and_return(false)
      subject
      expect(subject).to be_failure
    end

    it 'fails if id card duplication fails' do
      allow(template_guest).to receive(:id_card).and_return(double(:id_card))
      allow(SpreeCmCommissioner::IdCardDuplicator).to receive(:call).and_return(double(success?: false, message: 'Failed to duplicate ID card'))
      subject
      expect(subject).to be_failure
    end
  end

  context 'when template_guest_id is not provided' do
    before do
      allow(guest).to receive(:update).and_return(true)
    end

    it 'updates the guest with guest params' do
      expect(guest).to receive(:update).with(guest_params)
      described_class.call(guest: guest, guest_params: guest_params, template_guest_id: nil)
    end

    it 'fails if guest update fails' do
      allow(guest).to receive(:update).and_return(false)
      result = described_class.call(guest: guest, guest_params: guest_params, template_guest_id: nil)
      expect(result).to be_failure
    end
  end
end
