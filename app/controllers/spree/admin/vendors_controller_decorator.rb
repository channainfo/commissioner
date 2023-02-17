module Spree
  module Admin
    module VendorsControllerDecorator
      def self.prepended(base)
        base.before_action :build_logo, only: %i[create update]
      end

      private

      def build_logo
        return unless permitted_resource_params[:logo]

        @vendor.build_logo(attachment: permitted_resource_params.delete(:logo))
      end
    end
  end
end

Spree::Admin::VendorsController.prepend(Spree::Admin::VendorsControllerDecorator)
