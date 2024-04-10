FactoryBot.define do
  factory :review, class: Spree::Review do
    rating { 4 }
    title { FFaker::Lorem.sentence }
    name { FFaker::Name.name }
    review { FFaker::Lorem.sentence }
    show_identifier { 1 }
  end
end
