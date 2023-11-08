module Spree
  module Api
    module Webhook
      class BaseController < ::Spree::Api::V2::ResourceController
        before_action :load_subsriber

        protected

        def load_subsriber
          api_key = request.headers['X-Api-Key']
          api_name = request.headers['X-Api-Name']

          @subscriber = Spree::Webhooks::Subscriber.find_by(name: api_name, api_key: api_key)

          raise CanCan::AccessDenied if @subscriber.blank?
        end

        def authorized_subscriber!(resource)
          raise CanCan::AccessDenied unless @subscriber.authorized_to?(resource)
        end
      end
    end
  end
end
