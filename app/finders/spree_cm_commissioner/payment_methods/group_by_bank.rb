module SpreeCmCommissioner
  module PaymentMethods
    class GroupByBank
      def execute(payment_methods:, preferred_payment_method_id:)
        sorted_payment_methods = sort_payments(
          payment_methods: payment_methods,
          preferred_payment_method_id: preferred_payment_method_id
        )

        sorted_payment_methods.group_by(&:type).map do |type, methods|
          ::SpreeCmCommissioner::PaymentMethodGroup.new(
            name: type.underscore,
            payment_methods: methods
          )
        end
      end

      def sort_payments(payment_methods:, preferred_payment_method_id:)
        payment_methods.sort_by do |method|
          [preferred_payment_method_id == method.id ? 0 : 1, method.position]
        end
      end
    end
  end
end
