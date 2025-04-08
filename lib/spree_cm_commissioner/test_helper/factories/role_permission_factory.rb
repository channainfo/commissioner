FactoryBot.define do
  factory :permission, class: 'SpreeCmCommissioner::Permission' do
    entry { 'organizer/events' }
    action { 'view_events' }
  end

  factory :role_permission, class: 'SpreeCmCommissioner::RolePermission' do
    association :role, factory: :role
    association :permission, factory: :permission
  end
end