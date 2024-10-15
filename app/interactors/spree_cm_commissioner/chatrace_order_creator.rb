module SpreeCmCommissioner
  class ChatraceOrderCreator < BaseInteractor
    delegate :chatrace_user_id, :chatrace_return_flow_id,
             :chatrace_api_host, :chatrace_access_token,
             :guest_token, :order_params,
             to: :context

    def call
      context.order_creator = create_order
      return context.fail!(message: context.order_creator.message) unless context.order_creator.success?

      notify_user
    end

    def create_order
      SpreeCmCommissioner::OrderImporter::SingleGuest.call(
        guest_token: guest_token,
        params: order_params.slice(
          :order_email,
          :order_phone_number,
          :variant_id,
          *SpreeCmCommissioner::Guest.csv_importable_columns
        )
      )
    end

    def notify_user
      client = Faraday.new(
        url: "https://#{chatrace_api_host}",
        headers: {
          'X-ACCESS-TOKEN' => chatrace_access_token,
          'Content-Type' => 'application/json'
        }
      )

      response = client.post("/api/users/#{chatrace_user_id}/send/#{chatrace_return_flow_id}")
      context.fail!(message: 'notify_user_failed') unless response.status == 200
    end
  end
end
