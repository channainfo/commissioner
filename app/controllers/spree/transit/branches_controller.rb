module Spree
  module Transit
    class BranchesController < Spree::Transit::BaseController

      def new
        @branch = SpreeCmCommissioner::Branch.new
        super
      end

      def collection
        return @collection if defined?(@collection)
        current_vendor.branches

        @search = current_vendor.branches.ransack(params[:q])
        @collection = @search.result
      end

      def location_after_save
        transit_branches_url
      end

      def model_class
        SpreeCmCommissioner::Branch
      end

      def object_name
        'spree_cm_commissioner_branch'
      end

      def branch_params
        params.require(:branch).permit(:name, :lat, :lon)
      end
    end
  end
end
