FactoryBot.define do
  factory :invite_user_event, class: SpreeCmCommissioner::InviteUserEvent do
    invite { create(:invite) }
  end
end
