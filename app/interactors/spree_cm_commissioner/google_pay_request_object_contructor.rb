module SpreeCmCommissioner
  class GooglePayRequestObjectContructor < BaseInteractor
    def call
      google_pay_data = build_google_pay_request_object(context)
      token = generate_jwt_token(google_pay_data)
      context.token = token
    end

    private

    def build_google_pay_request_object(context)
      {
        provider: 'google_pay',
        data: {
          environment: ENV.fetch('GOOGLE_PAY_ENVIRONMENT', 'test'),
          apiVersion: 2,
          apiVersionMinor: 0,
          allowedPaymentMethods: [allowed_payment_method],
          merchantInfo: merchant_info(context),
          transactionInfo: transaction_info
        }
      }
    end

    def allowed_payment_method
      {
        type: 'CARD',
        tokenizationSpecification: tokenization_specification,
        parameters: payment_method_parameters
      }
    end

    def tokenization_specification
      {
        type: 'PAYMENT_GATEWAY',
        parameters: {
          gateway: ENV.fetch('GOOGLE_PAY_GATEWAY', nil),
          gatewayMerchantId: ENV.fetch('GOOGLE_PAY_GATEWAY_MERCHANT_ID', nil)
        }
      }
    end

    def payment_method_parameters
      {
        allowedCardNetworks: ENV.fetch('ALLOWED_CARD_NETWORKS', nil),
        allowedAuthMethods: ENV.fetch('ALLOWED_AUTH_METHODS', nil)
      }
    end

    def merchant_info(_context)
      {
        merchantId: ENV.fetch('GOOGLE_PAY_MERCHANT_ID', nil),
        merchantName: ENV.fetch('GOOGLE_PAY_MERCHANT_NAME', nil)
      }
    end

    def transaction_info
      {
        countryCode: 'US',
        currencyCode: 'USD'
      }
    end

    def generate_jwt_token(google_pay_data)
      JWT.encode(google_pay_data, signing_key, 'RS256')
    end

    def signing_key
      OpenSSL::PKey::RSA.new(credentials.private_key)
    end

    def credentials
      Rails.application.credentials.google_wallet_service_account
    end
  end
end
