require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CrewInviter do
  let!(:user) { create(:user, email: 'panha@example.com') }
  let!(:crew_invite) { create(:invite) }
  let!(:invite_user_event) { create(:invite_user_event, invite_id: crew_invite.id, email: user.email) }
  let!(:operator_role) { create(:role, name: 'operator') }

  before do
    allow(SpreeCmCommissioner::CrewInvite).to receive(:find).and_return(crew_invite)
    allow(Spree::Role).to receive(:find_by).and_return(operator_role)
  end

  describe 'assign_role_to_user' do
    it 'assigns operator role to user if not already assigned' do
      described_class.call(id: crew_invite.id , invitee_id: user.id)

      expect(user.reload.operator?).to eq true
    end
  end

  describe 'create_user_event' do
    it 'creates a user event successfully' do
      described_class.call(id: crew_invite.id , invitee_id: user.id)

      expect(invite_user_event.reload.user_event.event.name).to eq crew_invite.taxon.name
    end

    it 'fails if user is already invited' do
      create(:user_event, user: user, taxon_id: crew_invite.taxon_id)
      context = described_class.call(id: crew_invite.id , invitee_id: user.id)

      expect(context.message).to eq 'Failed: User already invited to event'
    end
  end

  describe 'update_invite_user_event' do
    it 'update invite_user_event successfully' do
      described_class.call(id: crew_invite.id , invitee_id: user.id)

      expect(invite_user_event.reload.user_event.event.name).to eq crew_invite.taxon.name
      expect(invite_user_event.confirmed_at).not_to be_nil
    end
  end

  describe 'validate_data' do
    it 'return error message: Invitation not found' do
      allow_any_instance_of(SpreeCmCommissioner::CrewInviter).to receive(:invite_user_event).and_return(nil)
      context = described_class.call(id: crew_invite.id , invitee_id: user.id)

      expect(context.message).to eq 'Invite link not found or have been expired'
    end

    it 'return error message: Invitation link is expired' do
      allow(crew_invite).to receive(:url_valid?).and_return(false)
      context = described_class.call(id: crew_invite.id, invitee_id: user.id)

      expect(context.message).to eq 'Invitation link is expired'
    end
  end
end
