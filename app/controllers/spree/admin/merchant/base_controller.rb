module Spree
  module Admin
    module Merchant
      class BaseController < Spree::Admin::ResourceController
        include SpreeCmCommissioner::Admin::RoleAuthorization

        layout 'spree/layouts/merchant'
        helper_method :current_vendor, :vendors

        before_action :required_merchant_user!
        before_action :redirect_with_default_params, unless: :contains_default_params?

        rescue_from SpreeCmCommissioner::UnauthorizedVendorError, with: :handle_unauthorized_vendor

        def handle_unauthorized_vendor
          redirect_to admin_merchant_forbidden_url
        end

        def required_merchant_user!
          return unless vendors.empty?

          raise SpreeCmCommissioner::UnauthorizedVendorError
        end

        def redirect_with_default_params
          redirect_to url_for(default_url_options)
        end

        def contains_default_params?
          current_vendor.present?
        end

        def default_url_options
          { vendor_id: current_vendor&.slug || vendors.first&.slug }
        end

        def vendors
          @vendors ||= spree_current_user.vendors.to_a
        end

        def current_vendor
          @current_vendor ||= vendors.select { |v| v.slug == params[:vendor_id] }.first
        end

        def page
          params[:page] || 1
        end

        def per_page
          params[:per_page] || 12
        end

        # @overrided
        def collection_url(options = {})
          if parent_data.present?
            spree.polymorphic_url([:admin, :merchant, parent, model_class], options)
          else
            spree.polymorphic_url([:admin, :merchant, model_class], options)
          end
        end
      end
    end
  end
end
