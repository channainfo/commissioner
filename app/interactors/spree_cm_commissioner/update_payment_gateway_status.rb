module SpreeCmCommissioner
  class UpdatePaymentGatewayStatus < BaseInteractor
    def call
      update_gateway_statuses
    end

    def update_gateway_status(payment_number)
      payment = Spree::Payment.find_by(number: payment_number)
      return unless payment

      payment.update_column(:gateway_status, true) # rubocop:disable Rails/SkipsModelValidations
    end

    def update_gateway_statuses
      payment_numbers.each do |payment_number|
        update_gateway_status(payment_number)
      end
    end

    private

    def payment_numbers
      file_name = Rails.root.join('db/data/payment_numbers.txt').to_s
      File.read(file_name).split.map(&:strip).reject(&:empty?)
    end
  end
end
