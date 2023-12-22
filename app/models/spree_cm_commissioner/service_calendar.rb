require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class ServiceCalendar < SpreeCmCommissioner::Base
    # exception_rules = [
    #   { 'from' => Date.parse('2023-1-01'), 'to'=> Date.parse('2023-1-31'), 'type' => 'exclusion', 'reason' => 'Company retreat' }
    # ]
    # inclusion: Service has been added for the specified date (default).
    # exclusion: Service has been removed for the specified date.
    include SpreeCmCommissioner::ServiceCalendarType
    EXCEPTION_RULE_JSON_SCHEMA = Pathname.new("#{COMMISSIONER_ROOT}/config/schemas/service_calendar_exception_rule.json")

    belongs_to :calendarable, polymorphic: true
    validates :exception_rules, json: { schema: EXCEPTION_RULE_JSON_SCHEMA }
    self.whitelisted_ransackable_attributes = %w[name]

    ## Callbacks
    before_save :set_dates

    def service_available?(date)
      exception_rule = get_exception_rule(date)
      # return bases on exception_rule first
      return exception_rule['type'] == 'inclusion' if exception_rule.present?

      service_started?(date) && in_weekly_service?(date)
    end

    def get_exception_rule(date)
      exception_rules.find do |rule|
        rule['from'].to_date <= date && date <= rule['to'].to_date
      end
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
