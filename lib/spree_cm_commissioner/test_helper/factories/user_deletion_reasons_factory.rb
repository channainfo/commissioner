FactoryBot.define do
  factory :user_deletion_reason do
    title { "account_deletion.title.sth_broken" }
    skip_reason { "" }
    reason_desc { "account_deletion.reason_description.sth_broken" }
  end
end