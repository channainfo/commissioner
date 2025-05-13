FactoryBot.define do
  factory :cm_transactional_email, class: SpreeCmCommissioner::TransactionalEmail do
    recipient_id { 1 }
    recipient_type { 'Spree::User'}
  end
end
