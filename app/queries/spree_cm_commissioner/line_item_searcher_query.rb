module SpreeCmCommissioner
  class LineItemSearcherQuery
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def call
      if @params[:qr_data].present?
        if order_qr_data?
          order = Spree::Order.search_by_qr_data!(@params[:qr_data])
          order.line_items.complete
        elsif line_item_qr_data?
          line_item_id = Spree::LineItem.search_by_qr_data!(@params[:qr_data]).id
          Spree::LineItem.complete.where(id: line_item_id)
        else
          guest = SpreeCmCommissioner::Guest.find_by!(token: @params[:qr_data])
          Spree::LineItem.complete.where(id: guest.line_item_id)
        end
      elsif @params[:term].present?
        search_by_ransack
      else
        search_by_guest_infos
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
      qr_data = @params[:qr_data]
      return nil unless qr_data

      if qr_data =~ /-L\d+$/
        qr_data.match(/(R\d+)-([A-Za-z0-9_\-]+)-(L\d+)/)&.captures
      else
        qr_data.match(/(R\d+)-([A-Za-z0-9_\-]+)/)&.captures
      end
    end

    def search_by_ransack
      terms = @params[:term].split
      event_id = @params[:event_id]

      Spree::LineItem
        .complete
        .joins('INNER JOIN cm_guests ON cm_guests.line_item_id = spree_line_items.id')
        .where(cm_guests: { event_id: event_id })
        .ransack(guests_first_name_or_guests_last_name_or_order_phone_number_or_order_email_or_order_number_cont_any: terms)
        .result
    end

    def search_by_guest_infos
      first_name = @params[:first_name]
      last_name = @params[:last_name]
      phone_number = @params[:phone_number]
      taxon_id = @params[:taxon_id]

      guests = SpreeCmCommissioner::Guest.complete
                                         .joins(line_item: { variant: { product: { classifications: { taxon: { parent: :parent } } } } })
                                         .joins(line_item: :order)

      if first_name.present? && last_name.present?
        guests = guests.where('LOWER(cm_guests.first_name) LIKE LOWER(?) AND LOWER(cm_guests.last_name) LIKE LOWER(?)',
                              "%#{first_name}%",
                              "%#{last_name}%"
                             )
      end

      guests = guests.where(spree_orders: { phone_number: phone_number }) if phone_number.present?

      guests = guests.where(parent: { id: taxon_id }) if taxon_id.present?

      line_item_ids = guests.map(&:line_item_id)
      Spree::LineItem.where(id: line_item_ids)
    end
  end
end
