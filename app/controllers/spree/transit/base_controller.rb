module Spree
  module Transit
    class BaseController < Spree::Admin::ResourceController
      helper_method :current_vendor, :vendors
      before_action :required_vendor_user!
      before_action :current_vendor
      layout 'spree/layouts/transit'

      def vendors
        @vendors ||= spree_current_user.vendors.to_a
      end

      def page
        params[:page] || 1
      end

      def per_page
        params[:per_page] || 12
      end

      # @overrided
      def required_vendor_user!
        return unless vendors.empty?

        raise SpreeCmCommissioner::UnauthorizedVendorError
      end

      def current_vendor
        @current_vendor ||= vendors.find { |v| v[:slug] == session[:transit_current_vendor_slug] } || vendors.first
        session[:transit_current_vendor_slug] ||= @current_vendor&.slug

        @current_vendor
      end

      def collection_url(options = {})
        if parent_data.present?
          spree.polymorphic_url([:transit, parent, model_class], options)
        else
          spree.polymorphic_url([:transit, model_class], options)
        end
      end

      def edit_object_url(object, options = {})
        if parent_data.present?
          spree.send "edit_transit_#{resource.model_name}_#{resource.object_name}_url",
                     parent, object, options
        else
          spree.send "edit_transit_#{resource.object_name}_url", object, options
        end
      end
    end
  end
end
