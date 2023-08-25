module SpreeCmCommissioner
  class TelegramWebAppInitDataValidator < BaseInteractor
    delegate :telegram_init_data, :bot_token, to: :context

    def call
      context.decoded_telegram_init_data = Rack::Utils.parse_nested_query(telegram_init_data).to_h

      context.initial_hash = context.decoded_telegram_init_data['hash']
      context.verify_hash = generate_verify_hash

      context.fail!(message: 'Could not verify hash') if context.verify_hash != context.initial_hash
    end

    # https://core.telegram.org/bots/webapps#validating-data-received-via-the-web-app
    #
    # data_check_string = <sorted alphabetically, in the format key=<value> with a line feed character ('\n', 0x0A) used as separator>
    # secret_key = HMAC_SHA256(<bot_token>, "WebAppData")
    # verify_hash = hex(HMAC_SHA256(data_check_string, secret_key))
    #
    def generate_verify_hash
      data_check_string = context.decoded_telegram_init_data.filter_map { |k, v| "#{k}=#{v}" unless k == 'hash' }.sort.join("\n")

      secret_key = OpenSSL::HMAC.digest('sha256', 'WebAppData', bot_token)
      OpenSSL::HMAC.hexdigest('sha256', secret_key, data_check_string)
    end
  end
end
