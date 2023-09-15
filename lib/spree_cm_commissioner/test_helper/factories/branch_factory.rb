FactoryBot.define do

  factory :cm_branch , class: SpreeCmCommissioner::Branch do
    name { 'testBranch'}
    lat { 11.11 }
    lon { 11.11}
    formatted_phone_number { generate(:phone_number) }
    formatted_address { "test_address" }
    state
    vendor
  end
end