module Spree
  module Admin
    class HomepageFeedController < Spree::Admin::ResourceController
      def edit
        @taxons = Spree::Taxon.all
        @vendors = Spree::Vendor.all
        @config = SpreeCmCommissioner::Configuration.new
      end

      def update
        @config = SpreeCmCommissioner::Configuration.new

        @config[:trending_category_taxon_ids] = params[:trending_category_taxon_ids]
        @config[:featured_vendor_ids] = params[:featured_vendor_ids]

        redirect_to spree.edit_admin_homepage_feed_path
      end

      def model_class
        SpreeCmCommissioner::HomepageFeed
      end

      def object_name
        'spree_cm_commissioner_homepage_feed'
      end
    end
  end
end
