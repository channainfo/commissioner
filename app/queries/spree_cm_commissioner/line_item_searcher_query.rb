module SpreeCmCommissioner
  class LineItemSearcherQuery
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def call
      qr_data = @params[:qr_data]

      if qr_data.present?
        order = Spree::Order.search_by_qr_data!(qr_data)
        order.line_items
      else
        search_by_guest_name
      end
    end

    def search_by_guest_name
      first_name = params[:first_name]
      last_name = params[:last_name]
      phone_number = params[:phone_number]
      taxon_id = params[:taxon_id]

      guests = SpreeCmCommissioner::Guest
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
