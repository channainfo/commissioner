module Spree
  module Billing
    class BaseController < Spree::Admin::ResourceController
      include SpreeCmCommissioner::Billing::RoleAuthorization

      layout 'spree/layouts/billing'
      helper_method :current_vendor, :vendors

      before_action :required_vendor_user!
      before_action :set_locale
      before_action :current_vendor

      rescue_from SpreeCmCommissioner::UnauthorizedVendorError, with: :handle_unauthorized_vendor

      def set_locale
        I18n.locale = params[:locale] || I18n.default_locale
      end

      def default_url_options(options = {})
        { locale: I18n.locale }.merge(options)
      end

      def handle_unauthorized_vendor
        redirect_to billing_forbidden_url
      end

      def required_vendor_user!
        return unless vendors.empty?

        raise SpreeCmCommissioner::UnauthorizedVendorError
      end

      def vendors
        @vendors ||= spree_current_user.vendors.to_a
      end

      def current_vendor
        @current_vendor ||= vendors.find { |v| v[:slug] == session[:billing_current_vendor_slug] } || vendors.first
        session[:billing_current_vendor_slug] ||= @current_vendor&.slug

        @current_vendor
      end

      def page
        params[:page] || 1
      end

      def per_page
        params[:per_page] || 25
      end

      # ajax
      def switch_vendor
        head :unprocessable_entity if request.xhr?

        exists = vendors.find { |v| v[:slug] == params[:slug] }
        session[:billing_current_vendor_slug] = params[:slug] if exists

        head exists ? :ok : :not_found
      end

      # @overrided
      def edit_object_url(object, options = {})
        if parent_data.present?
          spree.send "edit_billing_#{resource.model_name}_#{resource.object_name}_url",
                     parent, object, options
        else
          spree.send "edit_billing_#{resource.object_name}_url", object, options
        end
      end

      # @overrided
      def collection_url(options = {})
        if parent_data.present?
          spree.polymorphic_url([:billing, parent, model_class], options)
        else
          spree.polymorphic_url([:billing, model_class], options)
        end
      end
    end
  end
end
