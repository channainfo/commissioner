module Spree
  module Transit
    class ReservationsController < Spree::Transit::BaseController
      def index; end

      def model_class
        Spree::Order
      end

      def object_name
        'order'
      end
    end
  end
end
