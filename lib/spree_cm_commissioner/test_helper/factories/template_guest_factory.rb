FactoryBot.define do
  factory :template_guest, class: SpreeCmCommissioner::TemplateGuest do
    first_name { FFaker::Name.name }
    last_name { FFaker::Name.name }
    gender { 1 }
    dob { '2002-11-18' }
    is_default { false }
  end
end
