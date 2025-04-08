require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RolePermissionsLoader do
  let(:role) { create(:role) }
  let(:permissions_config) do
    {
      grouped: {
        'organizer/events' => {
          'view_events' => {
            'description' => 'Allows viewing event details',
            'actions' => ['index', 'show', 'overview_frame', 'event_list_frame']
          },
          'manage_events' => {
            'description' => 'Allows updating event details',
            'actions' => ['update', 'edit']
          }
        }
      }
    }
  end

  subject { described_class.new(role, permissions_config) }

  describe '#initialize' do
    it 'sets the role, permissions_config, and initializes role_permissions' do
      expect(subject.role).to eq(role)
      expect(subject.permissions_config).to eq(permissions_config)
      expect(subject.role_permissions).to eq([])
    end
  end

  describe '#call' do
    it 'loads role permissions and returns unique permissions by slug' do
      result = subject.call
      expect(result).to be_an(Array)
      expect(result.uniq(&:slug)).to eq(result)
    end
  end

  describe '#load_role_permissions' do
    it 'processes each entry and group from permissions_config' do
      subject.call
      expect(subject.role_permissions.count).to eq(2)
      view_permission = subject.role_permissions.find { |rp| rp.permission.action == 'view_events' }
      manage_permission = subject.role_permissions.find { |rp| rp.permission.action == 'manage_events' }
      expect(view_permission).to be_present
      expect(manage_permission).to be_present
      expect(view_permission.permission.entry).to eq('organizer/events')
      expect(manage_permission.permission.entry).to eq('organizer/events')
    end

    it 'skips groups with empty actions' do
      permissions_config[:grouped]['organizer/events']['empty_group'] = {
        'description' => 'Empty actions',
        'actions' => []
      }
      subject.call
      expect(subject.role_permissions.count).to eq(2) # Only view_events and manage_events
    end

    it 'processes each entry only once' do
      permissions_config[:grouped]['organizer/events_dup'] = permissions_config[:grouped]['organizer/events'].dup
      subject.call
      expect(subject.role_permissions.count).to eq(4) # 2 from each entry
    end
  end

  describe '#find_or_initialize_permission' do
    it 'finds existing permission or initializes a new one' do
      existing_permission = create(:permission, entry: 'organizer/events', action: 'view_events')
      permission = subject.send(:find_or_initialize_permission, 'organizer/events', 'view_events')
      expect(permission).to eq(existing_permission)

      new_permission = subject.send(:find_or_initialize_permission, 'organizer/events', 'new_action')
      expect(new_permission).to be_a(SpreeCmCommissioner::Permission)
      expect(new_permission).to be_new_record
    end
  end

  describe '#build_role_permission' do
    let(:permission) { create(:permission, entry: 'organizer/events', action: 'view_events') }

    context 'when role and permission are persisted' do
      it 'finds or initializes an existing role_permission' do
        existing_rp = create(:role_permission, role: role, permission: permission)
        role_permission = subject.send(:build_role_permission, permission)
        expect(role_permission).to eq(existing_rp)
      end
    end

    context 'when role or permission is not persisted' do # Fixed syntax here
      let(:unpersisted_role) { build(:role) }
      subject { described_class.new(unpersisted_role, permissions_config) }

      it 'creates a new role_permission without saving' do
        role_permission = subject.send(:build_role_permission, permission)
        expect(role_permission).to be_a(SpreeCmCommissioner::RolePermission)
        expect(role_permission).to be_new_record
        expect(role_permission.role).to eq(unpersisted_role)
        expect(role_permission.permission).to eq(permission)
      end
    end
  end
end