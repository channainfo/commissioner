module SmsAdapter
  module Twillio
    include ActiveSupport::Concern

    def create_message(options)
      client.messages.create(options)
    end

    def client
      @client ||= Twilio::REST::Client.new(
        Rails.application.credentials.twillio[:account_sid],
        Rails.application.credentials.twillio[:auth_token]
      )
    end

    def adapter_name
      'Twillio'
    end
  end
end
