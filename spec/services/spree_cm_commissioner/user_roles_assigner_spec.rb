require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserRolesAssigner do
  let(:user) { create(:cm_user) }
  let(:vendor) { create(:vendor) }
  let(:role1) { create(:cm_role, vendor_id: vendor.id, presentation: 'Role 1') }
  let(:role2) { create(:cm_role, vendor_id: vendor.id, presentation: 'Role 2') }

  describe '.create' do
    context 'when user is not found' do
      it 'returns failure' do
        result = described_class.create(user_id: 0, role_ids: [role1.id], vendor_id: vendor.id)
        expect(result[:success]).to be false
        expect(result[:message]).to eq I18n.t('user_roles_assigner.user_not_found')
      end
    end

    context 'when user is already assigned to vendor' do
      before { user.vendors << vendor }

      it 'returns failure' do
        result = described_class.create(user_id: user.id, role_ids: [role1.id], vendor_id: vendor.id)
        expect(result[:success]).to be false
        expect(result[:message]).to eq I18n.t('user_roles_assigner.user_already_assigned')
      end
    end

    context 'when role_ids are blank' do
      it 'returns failure' do
        result = described_class.create(user_id: user.id, role_ids: [], vendor_id: vendor.id)
        expect(result[:success]).to be false
        expect(result[:message]).to eq I18n.t('user_roles_assigner.roles_required')
      end
    end

    context 'when everything is valid' do
      it 'assigns roles and vendor to user' do
        result = described_class.create(user_id: user.id, role_ids: [role1.id], vendor_id: vendor.id)
        expect(result[:success]).to be true
        expect(user.reload.vendors).to include(vendor)
        expect(user.role_users.where(role_id: role1.id)).to exist
      end
    end
  end

  describe '.update' do
    before do
      user.vendors << vendor
      user.role_users.create(role: role1)
    end

    context 'when role_ids are blank' do
      it 'returns failure' do
        result = described_class.update(user_id: user.id, role_ids: [], vendor_id: vendor.id)
        expect(result[:success]).to be false
        expect(result[:message]).to eq I18n.t('user_roles_assigner.roles_required')
      end
    end

    context 'when updating roles' do
      it 'updates user roles' do
        result = described_class.update(user_id: user.id, role_ids: [role2.id], vendor_id: vendor.id)
        expect(result[:success]).to be true
        expect(user.role_users.pluck(:role_id)).to include(role2.id)
        expect(user.role_users.pluck(:role_id)).not_to include(role1.id)
        expect(user.role_users.where(role_id: role2.id, role: role2)).to exist
      end
    end
  end
end