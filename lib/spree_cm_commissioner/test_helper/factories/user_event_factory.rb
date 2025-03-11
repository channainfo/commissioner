FactoryBot.define do
  factory :user_event, class: SpreeCmCommissioner::UserEvent do
    taxon { create(:taxon) }
    user { create(:user) }
  end
end
