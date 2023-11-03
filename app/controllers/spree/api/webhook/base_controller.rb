module Spree
  module Api
    module Webhook
      class BaseController < ::Spree::Api::V2::ResourceController
        before_action :authorize_subscriber!

        protected

        def authorize_subscriber!
          api_key = request.headers['X-Api-Key']
          api_name = request.headers['X-Api-Name']

          raise CanCan::AccessDenied unless Spree::Webhooks::Subscriber.authorized?(api_name, api_key)
        end
      end
    end
  end
end
