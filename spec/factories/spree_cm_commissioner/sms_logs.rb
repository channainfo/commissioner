FactoryBot.define do
  factory :cm_sms_log, class: SpreeCmCommissioner::SmsLog do
    from_number { "" }
    to_number { "MyString" }
    body { "MyString" }
  end
end
