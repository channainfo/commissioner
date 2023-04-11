module Spree
  module Admin
    class HomePageFeedController < Spree::Admin::ResourceController

      def edit
        @taxons = Spree::Taxon.all
        @config = SpreeCmCommissioner::Configuration.new
      end

      def update
        @config = SpreeCmCommissioner::Configuration.new
        @config[:trending_category_taxon_ids] = params[:trending_category_taxon_ids]

        redirect_to spree.edit_admin_home_page_feed_path
      end


      def model_class
        SpreeCmCommissioner::HomePageFeed
      end

      def object_name
        'spree_cm_commissioner_home_page_feed'
      end
    end
  end
end
