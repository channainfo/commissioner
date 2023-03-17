module SpreeCmCommissioner
  class ApplyServiceAvailability < BaseInteractor
    delegate :calendarable, :from_date, :to_date, to: :context

    before do
      calendarable.respond_to?(:each) ? apply_availabilities : calculate_availabilities_for_date_range(calendarable)
    end

    # :calendarable
    def call
      context.value = calendarable
    end

    private

    def apply_availabilities
      calendarable.map { |resource| calculate_availabilities_for_date_range(resource) }
    end

    def calculate_availabilities_for_date_range(resource)
      resource.service_availabilities = (from_date..to_date).map do |date|
        { date: date.to_s, available: check_availability(resource, date) }
      end
    end

    def check_availability(resource, date)
      # no n+1 database query because regular_service_calendars is array
      service_calendar = regular_service_calendars.find { |s| s.calendarable_id == resource.id }
      # service is available as default
      service_calendar ? service_calendar.service_available?(date) : true
    end

    def regular_service_calendars
      @regular_service_calendars ||= SpreeCmCommissioner::ServiceCalendar.includes(:service_calendar_dates)
                                                                         .where('start_date <= ? AND end_date >= ?', from_date, to_date)
                                                                         .where(calendarable_id: calendarable_ids)
                                                                         .where(calendarable_type: calendarable_type)
                                                                         .order(created_at: :desc)
                                                                         .to_a
    end

    def calendarable_ids
      calendarable.respond_to?(:each) ? calendarable.map(&:id).uniq : calendarable.id
    end

    def calendarable_type
      calendarable.respond_to?(:each) ? calendarable.klass.name : calendarable.class.name
    end
  end
end
