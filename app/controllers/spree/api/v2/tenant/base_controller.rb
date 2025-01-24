module Spree
  module Api
    module V2
      module Tenant
        class BaseController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          set_current_tenant_through_filter
          before_action :require_tenant

          def require_tenant
            raise Doorkeeper::Errors::DoorkeeperError if doorkeeper_token&.application.nil?
            raise Doorkeeper::Errors::DoorkeeperError if doorkeeper_token.application.tenant.nil?

            @tenant = doorkeeper_token.application.tenant
            set_current_tenant(@tenant)
          end

          def render_serialized_payload(status = 200)
            render json: yield, status: status, content_type: content_type
          end
        end
      end
    end
  end
end
