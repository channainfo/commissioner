module Spree
  module Admin
    class HomepageSectionRelatableController < Spree::Admin::ResourceController
      @vendor = Spree::Vendor
      @taxon = Spree::Taxon
      @product = Spree::Product

      def model_class
        SpreeCmCommissioner::HomepageSectionRelatable
      end

      def object_name
        'spree_cm_commissioner_homepage_section_relatable'
      end

      def collection_url(options = {})
        admin_homepage_feed_homepage_section_relatable_index_url(options)
      end

      def location_after_save
        edit_admin_homepage_feed_homepage_section_url(@object.homepage_section_id)
      end

      def options
        relatable_type = params[:relatable_type]
        options =
          case relatable_type
          when 'Spree::Vendor'
            Spree::Vendor.all.map { |vendor| [vendor.name, vendor.id] }
          when 'Spree::Taxon'
            Spree::Taxon.all.map { |taxon| [taxon.name, taxon.id] }
          when 'Spree::Product'
            Spree::Product.all.map { |product| [product.name, product.id] }
          else
            []
          end
        render json: options
      end

      def permitted_resource_params
        params.permit(:homepage_section_id, :relatable_id, :relatable_type)
      end
    end
  end
end
