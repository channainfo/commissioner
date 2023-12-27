FactoryBot.define do
  factory :id_card , class: SpreeCmCommissioner::IdCard do
    card_type { 1 }
    guest { create(:guest) }
  end
end