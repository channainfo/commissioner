module SpreeCmCommissioner
  class LineItemSearcherQuery
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def event_id = params[:event_id]

    def call
      return Spree::LineItem.none if params[:event_id].blank?

      if params[:qr_data].present? && order_qr_data?
        search_by_order_qr
      elsif params[:qr_data].present? && line_item_qr_data?
        search_by_line_item_qr
      elsif params[:qr_data].present?
        search_by_guest_qr
      elsif params[:term].present?
        search_by_ransack
      else
        all_line_items
      end
    end

    private

    def order_qr_data?
      matches = construct_matches
      matches&.size == 2
    end

    def line_item_qr_data?
      matches = construct_matches
      matches&.size == 3
    end

    def guest_qr_data?
      matches = construct_matches
      matches.nil?
    end

    def construct_matches
      qr_data = params[:qr_data]
      return nil unless qr_data

      if qr_data =~ /-L\d+$/
        qr_data.match(/(R\d+)-([A-Za-z0-9_\-]+)-(L\d+)/)&.captures
      else
        qr_data.match(/(R\d+)-([A-Za-z0-9_\-]+)/)&.captures
      end
    end

    def search_by_order_qr
      order = Spree::Order.complete.search_by_qr_data!(params[:qr_data])
      order.line_items
           .joins(:guests)
           .where(guests: { event_id: event_id })
           .distinct
    end

    def search_by_line_item_qr
      line_item_id = Spree::LineItem.complete.search_by_qr_data!(params[:qr_data])&.id

      Spree::LineItem
        .joins(:guests)
        .where(id: line_item_id, guests: { event_id: event_id })
        .distinct
    end

    def search_by_guest_qr
      guest = SpreeCmCommissioner::Guest.complete.find_by!(token: params[:qr_data], event_id: event_id)

      Spree::LineItem.where(id: guest&.line_item_id)
    end

    def search_by_ransack
      terms = params[:term].split.map { |term| "%#{term.downcase}%" }

      Spree::LineItem
        .complete
        .joins(:guests)
        .where(guests: { event_id: event_id })
        .where(
          "LOWER(spree_orders.number) LIKE ANY (ARRAY[:terms]) OR
          LOWER(spree_line_items.number) LIKE ANY (ARRAY[:terms]) OR
          LOWER(spree_orders.phone_number) LIKE ANY (ARRAY[:terms]) OR
          LOWER(spree_orders.email) LIKE ANY (ARRAY[:terms]) OR
          LOWER(guests.first_name) LIKE ANY (ARRAY[:terms]) OR
          LOWER(guests.last_name) LIKE ANY (ARRAY[:terms])",
          { terms: terms }
        )
        .distinct
    end

    def all_line_items
      Spree::LineItem
        .complete
        .joins(:guests)
        .where(guests: { event_id: event_id })
        .distinct
    end
  end
end
