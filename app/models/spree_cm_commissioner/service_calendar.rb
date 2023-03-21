require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class ServiceCalendar < ApplicationRecord
    ## Callbacks
    before_save :set_dates

    belongs_to :calendarable, polymorphic: true
    has_many   :service_calendar_dates, class_name: 'SpreeCmCommissioner::ServiceCalendarDate'

    def service_available?(date)
      # date on exception_calendar is unique
      exception_calendar = service_calendar_dates.to_a.find { |s| s.date.to_s == date.to_s }
      return exception_calendar.inclusion? if exception_calendar.present?

      service_started?(date) && in_weekly_service?(date)
    end

    private

    def set_dates
      self.start_date = Date.new(2000, 1, 1) if start_date.blank?
      self.end_date   = Date.new(2100, 1, 1) if end_date.blank?
    end

    def in_weekly_service?(date)
      day_name = date.strftime('%A').downcase
      send(day_name.to_sym)
    end

    def service_started?(date)
      start_date <= date && date <= end_date
    end
  end
end
