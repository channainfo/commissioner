module SpreeCmCommissioner
  module LineItemsFilterScope
    extend ActiveSupport::Concern

    included do
      scope :complete, -> { joins(:order).merge(Spree::Order.complete.not_canceled) }
      scope :complete_or_canceled, -> { joins(:order).merge(Spree::Order.complete_or_canceled) }
      scope :canceled, -> { joins(:order).where.not(spree_orders: { canceled_at: nil }) }

      scope :accepted, -> { joins(:order).merge(Spree::Order.accepted) }
      scope :paid, -> { joins(:order).merge(Spree::Order.paid) }
      scope :with_bib_prefix, -> { joins(:option_types).where(option_types: { name: 'bib-prefix' }) }

      scope :filter_by_event, lambda { |event|
        case event
        when 'upcoming'
          complete_or_canceled.paid.where.not(to_date: nil).where('to_date >= ?', Time.zone.now)
                              .joins(:order).where(spree_orders: { canceled_at: nil })

        when 'complete'
          complete_or_canceled.paid.where.not(to_date: nil).where('to_date < ?', Time.zone.now)
                              .joins(:order).where(spree_orders: { canceled_at: nil })

        when 'canceled'
          canceled
        else
          none
        end
      }

      def event_status
        if order.canceled_at.present?
          'canceled'
        elsif to_date.present? && to_date < Time.zone.now
          'complete'
        elsif to_date.present? && to_date >= Time.zone.now
          'upcoming'
        end
      end
    end
  end
end
