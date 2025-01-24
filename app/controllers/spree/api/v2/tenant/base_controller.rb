module Spree
  module Api
    module V2
      module Tenant
        class BaseController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          set_current_tenant_through_filter
          before_action :set_host_as_tenant

          def render_serialized_payload(status = 200)
            render json: yield, status: status, content_type: content_type
          end

          def set_host_as_tenant
            @tenant = SpreeCmCommissioner::Tenant.find_by(name: request.host)
            set_current_tenant(@tenant) if @tenant
          end
        end
      end
    end
  end
end
