module Spree
  module Admin
    class TenantsController < Spree::Admin::ResourceController
      # override
      def collection
        params[:q] = {} if params[:q].blank?
        tenants = super.order(created_at: :asc)
        @search = tenants.ransack(params[:q])

        @collection = @search.result
                             .page(params[:page])
                             .per(params[:per_page])
      end

      # override
      def find_resource
        SpreeCmCommissioner::Tenant.friendly.find(params[:id])
      end

      # override
      def model_class
        SpreeCmCommissioner::Tenant
      end

      # override
      def object_name
        'spree_cm_commissioner_tenant'
      end

      # override
      def collection_url(options = {})
        admin_tenants_url(options)
      end
    end
  end
end
