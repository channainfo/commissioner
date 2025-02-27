require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserRolesAssigner do

  let(:user) { create(:user) }
  let(:role1) { create(:role, name: 'admin') }
  let(:role2) { create(:role, name: 'operator') }
  let(:role_ids) { [role1, role2] }

  subject { described_class.call(context) }

  context 'when user not found' do
    let(:context) { { user_id: 1, role_ids: role_ids } }
    it 'fails with a "User not found" message' do
      expect(subject.message).to eq I18n.t('user_roles_assigner.user_not_found')
    end
  end

  context 'when selected roles is empty' do
    let(:context) { { user_id: user.id, role_ids: [] } }
    it 'fails with a "Role selection cannot be empty' do
      expect(subject.message).to eq I18n.t('user_roles_assigner.roles_empty')
    end
  end

  context 'when user roles successfully update' do
    let(:context) { { user_id: user.id, role_ids: [role1.id, role2.id] } }
    it 'return success with user updated roles ' do
      subject.call
      role_ids.each do |role_id|
        expect(user.role_users.exists?(role_id: role_id)).to be true
      end
    end
  end
end
