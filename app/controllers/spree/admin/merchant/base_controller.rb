module Spree
  module Admin
    module Merchant
      class BaseController < Spree::Admin::ResourceController
        layout 'spree/layouts/merchant'
        helper_method :current_vendor, :vendors

        before_action :required_merchant_user!
        before_action :redirect_with_default_params, unless: :contains_default_params?

        rescue_from SpreeCmCommissioner::UnauthorizedVendorError, with: :handle_unaithorized_vendor

        def handle_unaithorized_vendor
          redirect_to admin_merchant_forbidden_path
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
          { slug: current_vendor&.slug || vendors.first&.slug }
        end

        def vendors
          @vendors ||= spree_current_user.vendors
        end

        def current_vendor
          @current_vendor ||= vendors.find_by(slug: params[:slug])
        end
      end
    end
  end
end
