FactoryBot.define do

  factory :cm_stop , class: SpreeCmCommissioner::Stop do
    code { 'TS'}
    name { 'testStop'}
    formatted_phone_number { generate(:phone_number) }
    formatted_address { "test_address" }
    lat { 11.11 }
    lon { 11.11}
    branch { create(:cm_branch) }
    state
    vendor
  end
end
