require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class ServiceCalendarDate < ApplicationRecord
    # inclusion: Service has been added for the specified date (default).
    # exclusion: Service has been removed for the specified date.
    enum exception_type: { :inclusion => 1, :exclusion => 2 }

    validates :date, presence: true

    belongs_to :service_calendar
  end
end
