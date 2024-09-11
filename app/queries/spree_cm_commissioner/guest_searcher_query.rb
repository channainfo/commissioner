module SpreeCmCommissioner
  class GuestSearcherQuery
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def event_id = params[:event_id]

    def call
      return SpreeCmCommissioner::Guest.none if event_id.blank?

      if params[:qr_data].present?
        search_by_guest_qr
      elsif params[:term].present?
        search_by_term
      else
        SpreeCmCommissioner::Guest.none
      end
    end

    private

    def search_by_guest_qr
      SpreeCmCommissioner::Guest.complete_or_canceled.where(
        token: params[:qr_data],
        event_id: event_id
      )
    end

    def search_by_term
      terms = params[:term].split.map { |term| "%#{term.downcase}%" }

      SpreeCmCommissioner::Guest
        .complete_or_canceled
        .joins(line_item: :order)
        .where(event_id: event_id)
        .where(
          "LOWER(spree_orders.number) LIKE ANY (ARRAY[:terms]) OR
          LOWER(spree_line_items.number) LIKE ANY (ARRAY[:terms]) OR
          LOWER(spree_orders.phone_number) LIKE ANY (ARRAY[:terms]) OR
          LOWER(spree_orders.email) LIKE ANY (ARRAY[:terms]) OR
          LOWER(cm_guests.first_name) LIKE ANY (ARRAY[:terms]) OR
          LOWER(cm_guests.last_name) LIKE ANY (ARRAY[:terms]) OR
          LOWER(cm_guests.seat_number) LIKE ANY (ARRAY[:terms]) OR
          LOWER(cm_guests.phone_number) LIKE ANY (ARRAY[:terms])",
          { terms: terms }
        )
        .distinct
    end
  end
end
