require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RolePermissionsConstructor do
  let(:role) { create(:role) }
  let(:permission) { create(:permission, entry: 'organizer/events', action: 'view_events') }
  let(:role_permission) { create(:role_permission, role: role, permission: permission) }

  subject { described_class.new(params) }

  describe '#initialize' do
    context 'when params include role_permissions_attributes' do
      let(:params) do
        { role_permissions_attributes: { '0' => { id: role_permission.id, selected: 'true' } } }
      end

      it 'sets @params to role_permissions_attributes' do
        expect(subject.instance_variable_get(:@params)).to eq(params[:role_permissions_attributes])
      end
    end

    context 'when params do not include role_permissions_attributes' do
      let(:params) { {} }

      it 'sets @params to an empty hash' do
        expect(subject.instance_variable_get(:@params)).to eq({})
      end
    end
  end

  describe '#call' do
    let(:params) { { role_permissions_attributes: { '0' => { id: '1', selected: 'true' } } } }

    it 'returns the result of construct_role_permissions' do
      allow(subject).to receive(:construct_role_permissions).and_return({ '0' => { id: '1' } })
      expect(subject.call).to eq({ '0' => { id: '1' } })
    end
  end

  describe '#construct_role_permissions' do
    context 'with selected role permissions' do
      let(:params) do
        {
          role_permissions_attributes: {
            '0' => {
              'id' => role_permission.id.to_s,
              'permission_attributes' => { 'id' => permission.id.to_s },
              'selected' => 'true'
            }
          }
        }
      end

      it 'includes selected role permissions with permission_id' do
        result = subject.call
        expect(result['0']).to eq({
          id: role_permission.id.to_s,
          permission_id: permission.id.to_s
        })
      end
    end

    context 'with unselected persisted role permissions' do
      let(:params) do
        {
          role_permissions_attributes: {
            '0' => {
              'id' => role_permission.id.to_s,
              'permission_attributes' => { 'id' => permission.id.to_s },
              'selected' => 'false'
            }
          }
        }
      end

      it 'marks persisted role permissions for destruction' do
        result = subject.call
        expect(result['0']).to eq({
          id: role_permission.id.to_s,
          permission_id: permission.id.to_s,
          _destroy: 1
        })
      end
    end

    context 'with unselected non-persisted role permissions' do
      let(:params) do
        {
          role_permissions_attributes: {
            '0' => {
              'permission_attributes' => { 'id' => permission.id.to_s },
              'selected' => 'false'
            }
          }
        }
      end

      it 'excludes non-persisted unselected role permissions' do
        result = subject.call
        expect(result).to eq({})
      end
    end

    context 'with mixed role permissions' do
      let(:params) do
        {
          role_permissions_attributes: {
            '0' => {
              'id' => role_permission.id.to_s,
              'permission_attributes' => { 'id' => permission.id.to_s },
              'selected' => 'true'
            },
            '1' => {
              'id' => (role_permission.id.to_s + '1'),
              'permission_attributes' => { 'id' => (permission.id.to_s + '1') },
              'selected' => 'false'
            },
            '2' => {
              'permission_attributes' => { 'id' => (permission.id.to_s + '2') },
              'selected' => 'false'
            }
          }
        }
      end

      it 'processes selected and persisted unselected permissions correctly' do
        result = subject.call
        expect(result).to eq({
          '0' => {
            id: role_permission.id.to_s,
            permission_id: permission.id.to_s
          },
          '1' => {
            id: (role_permission.id.to_s + '1'),
            permission_id: (permission.id.to_s + '1'),
            _destroy: 1
          }
        })
      end
    end

    context 'with new permission attributes' do
      let(:params) do
        {
          role_permissions_attributes: {
            '0' => {
              'permission_attributes' => { 'entry' => 'new/entry', 'action' => 'new_action' },
              'selected' => 'true'
            }
          }
        }
      end

      it 'keeps permission_attributes if permission is not persisted' do
        result = subject.call
        expect(result['0']).to eq({
          permission_attributes: { 'entry' => 'new/entry', 'action' => 'new_action' }
        })
      end
    end
  end
end
