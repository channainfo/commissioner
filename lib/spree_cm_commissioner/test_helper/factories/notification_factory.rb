FactoryBot.define do
  factory :notification, class: SpreeCmCommissioner::Notification do
    notificable(factory: :order)
    recipient(factory: :cm_user)
    type { '' }
    params { '' }
  end
end