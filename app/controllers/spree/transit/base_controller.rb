module Spree
  module Transit
    class BaseController < Spree::Admin::ResourceController
      helper_method :current_vendor, :vendors
      before_action :current_vendor
      layout 'spree/layouts/transit'

      def vendors
        @vendors ||= spree_current_user.vendors.to_a
      end

      def current_vendor
        @current_vendor ||= vendors.find { |v| v[:slug] == session[:transit_current_vendor_slug] } || vendors.first
        session[:transit_current_vendor_slug] ||= @current_vendor&.slug

        @current_vendor
      end
    end
  end
end
