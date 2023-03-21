FactoryBot.define do
  factory :cm_service_calendar, class: SpreeCmCommissioner::ServiceCalendar do
    start_date    { Date.new(2000, 1, 1) }
    end_date      { Date.new(2100, 1, 1) }
    calendarable  { create(:vendor) }

    factory :cm_service_calendar_no_available do
      monday    { false }
      tuesday   { false }
      wednesday { false }
      thursday  { false }
      friday    { false }
      saturday  { false }
      sunday    { false }
    end
  end
end