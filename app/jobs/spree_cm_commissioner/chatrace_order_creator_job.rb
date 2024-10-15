module SpreeCmCommissioner
  class ChatraceOrderCreatorJob < ApplicationJob
    # :chatrace_user_id, :chatrace_return_flow_id, :chatrace_api_host, :chatrace_access_token
    # :guest_token, :order_params
    def perform(options)
      SpreeCmCommissioner::ChatraceOrderCreator.call(options)
    end
  end
end
