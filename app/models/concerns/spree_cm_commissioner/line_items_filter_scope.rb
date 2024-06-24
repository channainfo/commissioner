module SpreeCmCommissioner
  module LineItemsFilterScope
    extend ActiveSupport::Concern

    included do
      scope :complete, -> { joins(:order).merge(Spree::Order.complete.not_canceled) }
      scope :accepted, -> { joins(:order).merge(Spree::Order.accepted) }
      scope :paid, -> { joins(:order).merge(Spree::Order.paid) }

      scope :filter_by_event, lambda { |event|
        case event
        when 'upcoming'
          where.not(to_date: nil).where('to_date >= ?', Time.zone.now)

        when 'complete'
          where.not(to_date: nil).where('to_date < ?', Time.zone.now)

        else
          none
        end
      }

      def event_status
        return 'upcoming' if to_date.present? && to_date >= Time.zone.now

        'complete' if to_date.present? && to_date < Time.zone.now
      end
    end
  end
end
