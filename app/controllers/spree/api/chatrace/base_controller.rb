module Spree
  module Api
    module Chatrace
      class BaseController < ::Spree::Api::V2::BaseController
        before_action :validate_token_client

        def validate_token_client
          raise Doorkeeper::Errors::DoorkeeperError if doorkeeper_token&.application.nil?
        end
      end
    end
  end
end
