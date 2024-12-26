# Override to reject setting billing/shipping addresses for guest orders if no basic information is provided.
#
# Without this safeguard, Spree may associate the order with a random existing address using the following default behavior:
# ::Spree::Address.find_or_create_by(attributes.except(:id, :updated_at, :created_at))
module SpreeCmCommissioner
  module Order
    module AddressBookDecorator
      def guest_order? = user.blank?

      # override
      def bill_address_attributes=(attributes)
        attributes[:id] = bill_address&.id if attributes[:id].blank?
        return if guest_order? && !basic_info_included?(attributes)

        super
      end

      # override
      def ship_address_attributes=(attributes)
        attributes[:id] = bill_address&.id if attributes[:id].blank?
        return if guest_order? && !basic_info_included?(attributes)

        super
      end

      private

      def basic_info_included?(attributes)
        return true if attributes[:id].present?

        %i[firstname lastname phone].all? { |key| attributes[key].present? }
      end
    end
  end
end

unless Spree::Order::AddressBook.included_modules.include?(SpreeCmCommissioner::Order::AddressBookDecorator)
  Spree::Order::AddressBook.prepend(SpreeCmCommissioner::Order::AddressBookDecorator)
end
