FactoryBot.define do
  factory :line_item_seat, class: SpreeCmCommissioner::LineItemSeat do
    line_item_id {}
    seat_id {}
    date { Date.today }
  end
end
