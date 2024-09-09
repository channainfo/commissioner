module Spree
  module Admin
    module UsersControllerDecorator
      def self.prepended(base)
        base.before_action :build_profile, only: %i[create update]
      end

      private

      def build_profile
        return unless permitted_resource_params[:profile]

        @user.build_profile(attachment: permitted_resource_params.delete(:profile))
      end
    end
  end
end

Spree::Admin::UsersController.prepend(Spree::Admin::UsersControllerDecorator)
