module SpreeCmCommissioner
  class CreateTicket
    include Interactor
    delegate :params, to: :context

    def call
      ActiveRecord::Base.transaction do
        create_ticket
        set_option_value
        create_variant
        create_stock_item
      end
    end

    private

    def create_ticket
      @ticket = Spree::Product.new(ticket_params)

      assign_store
      assign_event
      return if @ticket.save

      context.fail!(message: @ticket.errors.full_messages.join(', '))
    end

    def assign_store
      @store = Spree::Store.default
      @ticket.stores << @store
    end

    def assign_event
      # Find the event taxon using the event_id from the parameters.
      # It looks for a taxon with a slug like "events-{event_id}" and picks its first child.
      @event = Spree::Taxon.find_by(slug: "events-#{params[:event_id]}")&.children&.first
      if @event
        @ticket.taxons << @event
      else
        context.fail!(message: 'Event not found.')
      end
    end

    def set_option_value
      @option_type = Spree::OptionType.find_or_create_by!(
        name: 'ticket-type',
        presentation: 'Ticket Type'
      )

      @option_value = Spree::OptionValue.find_or_create_by!(
        name: @ticket.name,
        presentation: @ticket.name,
        option_type_id: @option_type.id
      )
    end

    def create_variant
      @variant = @ticket.variants.new(
        price: @ticket.price,
        compare_at_price: @ticket.compare_at_price,
        option_value_ids: [@option_value.id]
      )
      return if @variant.save

      context.fail!(message: @variant.errors.full_messages.join(', '))
    end

    def create_stock_item
      @stock_item = Spree::StockItem.new(
        variant_id: @variant.id,
        stock_location_id: context.params[:stock_location_id],
        count_on_hand: context.params[:count_on_hand]
      )
      return if @stock_item.save

      context.fail!(message: @stock_item.errors.full_messages.join(', '))
    end

    def ticket_params
      {
        name: context.params[:name],
        price: context.params[:price],
        compare_at_price: context.params[:compare_at_price],
        max_order_quantity: context.params[:max_order_quantity],
        available_on: context.params[:available_on],
        discontinue_on: context.params[:discontinue_on],
        description: context.params[:description],
        product_type: context.params[:product_type],
        vendor_id: context.params[:vendor_id],
        status: context.params[:status],
        shipping_category_id: context.params[:shipping_category_id],
        option_type_ids: context.params[:option_type_ids]
      }
    end
  end
end
