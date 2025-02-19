FactoryBot.define do
  factory :cm_check_in, class: SpreeCmCommissioner::CheckIn do
    confirmed_at { DateTime.current }
    check_in_type { "pre_check_in" }
    guest_id { 1 }
    check_in_method { "manual" }
    verification_state { "submitted" }
  end
end
