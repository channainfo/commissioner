module Spree
  module Admin
    module CmsPagesControllerDecorator
      def scope
        return Spree::CmsPage.none unless current_store&.cms_pages

        scope = current_store.cms_pages

        case params[:tab]
        when 'default'
          scope = scope.where(tenant_id: nil)
        when 'tenants'
          scope = if params[:tenant_id].present?
                    scope.where(tenant_id: params[:tenant_id])
                  else
                    scope.where.not(tenant_id: nil)
                  end
        end

        scope
      end

      def permitted_resource_params
        super.merge(tenant_id: params[:cms_page][:tenant_id])
      end
    end
  end
end

unless Spree::Admin::CmsPagesController.included_modules.include?(Spree::Admin::CmsPagesControllerDecorator)
  Spree::Admin::CmsPagesController.prepend(Spree::Admin::CmsPagesControllerDecorator)
end
