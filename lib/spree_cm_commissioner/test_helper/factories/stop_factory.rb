FactoryBot.define do

  factory :cm_stop , class: SpreeCmCommissioner::Place do
    code { 'TS'}
    name { 'testStop'}
    formatted_phone_number { generate(:phone_number) }
    formatted_address { "test_address" }
    lat { 11.11 }
    lon { 11.11}
    branch
    state
    vendor
  end
end