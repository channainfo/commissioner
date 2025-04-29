module Spree
  module Admin
    module PrototypesControllerDecorator
      def self.prepended(base)
        base.before_action :load_icons
      end

      # overrided
      def find_resource
        Spree::Prototype.friendly.find(params[:id])
      end

      def load_icons
        @icons = SpreeCmCommissioner::VectorIcon.all
      end
    end
  end
end

Spree::Admin::PrototypesController.prepend(Spree::Admin::PrototypesControllerDecorator)
