FactoryBot.define do
  factory :id_card , class: SpreeCmCommissioner::IdCard do
    card_type { 1 }
    guest { create(:guest) }
    front_image { create(:cm_front_image) }
    back_image { create(:cm_back_image) }
  end
end