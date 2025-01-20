module SpreeCmCommissioner
  module Orders
    module GenerateCommissionsDecorator
      # override
      def generate_order_commissions(order:)
        return failure(order) unless order.state == 'complete'

        vendor_commissions = generate_commissions_group_by_vendor_ids(order)
        vendor_commissions.each do |vendor_id, amount|
          order.commissions.find_or_create_by!(vendor_id: vendor_id) { |commission| commission.amount = amount }
        end

        success(order: order)
      end

      def generate_commissions_group_by_vendor_ids(order)
        order.line_items.each_with_object(Hash.new(0)) do |line_item, commissions|
          commissions[line_item.vendor_id] += commission_amount(line_item) if line_item.vendor_id.present?
        end
      end

      # return default line item commission amount
      # spree_vpago have different construction of commision.
      # if they define, should follow them.
      def commission_amount(line_item)
        return line_item.commission_amount if line_item.respond_to?(:commission_amount)

        line_item.pre_tax_amount * line_item.commission_rate / 100.0
      end
    end
  end
end

unless Spree::Orders::GenerateCommissions.included_modules.include?(SpreeCmCommissioner::Orders::GenerateCommissionsDecorator)
  Spree::Orders::GenerateCommissions.prepend(SpreeCmCommissioner::Orders::GenerateCommissionsDecorator)
end
