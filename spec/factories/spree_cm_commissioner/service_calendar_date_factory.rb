FactoryBot.define do
  factory :cm_service_calendar_date, class: SpreeCmCommissioner::ServiceCalendarDate do
    date             { Date.today }
    exception_type   { :inclusion }
    service_calendar { service_calendar }
  end
end