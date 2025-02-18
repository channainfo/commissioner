module Spree
  module Api
    module V2
      module Tenant
        class BaseController < ::Spree::Api::V2::ResourceController
          include Spree::Api::V2::CollectionOptionsHelpers

          set_current_tenant_through_filter
          before_action :require_tenant
          around_action :set_tenant_context

          def require_tenant
            raise Doorkeeper::Errors::DoorkeeperError if doorkeeper_token&.application.nil?
            raise Doorkeeper::Errors::DoorkeeperError if doorkeeper_token.application.tenant.nil?

            @tenant = doorkeeper_token.application.tenant
            set_current_tenant(@tenant)
          end

          def render_serialized_payload(status = 200)
            render json: yield, status: status, content_type: content_type
          end

          private

          def set_tenant_context
            MultiTenant.with(@tenant) do # rubocop:disable Style/ExplicitBlockArgument
              yield
            end
          end

          # override
          def scope
            raise 'scope should be implemented in a sub-class'
          end
        end
      end
    end
  end
end
