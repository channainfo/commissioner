FactoryBot.define do
  factory :guest, class: SpreeCmCommissioner::Guest do
    line_item { create(:line_item) }
    first_name { FFaker::Name.name }
    last_name { FFaker::Name.name }
    gender { 1 }
    dob { '1986-03-28' }
  end
end
