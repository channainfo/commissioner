FactoryBot.define do
  factory :guest, class: SpreeCmCommissioner::Guest do
    line_item { |a| a.association(:line_item) }
    first_name { FFaker::Name.name }
    last_name { FFaker::Name.name }
    gender { 1 }
    dob { '1986-03-28' }
    token { SecureRandom.hex(32) }
  end
end
