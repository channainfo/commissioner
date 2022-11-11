# @spree_cm_commissioner_vendor_photo is created by resource controller
# @spree_cm_commissioner_vendor_photo is equivalent to @object
# 
# Override model_class & object_name, 
# if object_name does not match the controller name
#
# Example. 
# - object is 'Spree::Image'
# - controller VendorPhotosController, not ImagesController
#
# So:
# > override model_class to Spree::Image
# > override object_name to spree_image
#
module Spree
  module Admin
    class VendorPhotosController < Spree::Admin::ResourceController
      before_action :load_vendor

      create.before :set_viewable
      update.before :set_viewable

      def load_vendor
        @vendor ||= Spree::Vendor.find_by(slug: params[:vendor_id])
        @vendor ||= Spree::Vendor.find_by(id: params[:vendor_id])
      end

      # while create or update params changed
      def set_viewable
        load_vendor

        @object.viewable_type = viewable_type
        @object.viewable_id = viewable_id
      end

      def viewable_type
        @vendor.class.name
      end

      def viewable_id
        @vendor.id
      end

      # @overrided
      def collection
        load_vendor # load on redirected after create, update

        @objects = model_class.where(
          viewable_type: viewable_type,
          viewable_id: viewable_id,
        )
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::VendorPhoto
      end

      # form_for :spree_cm_commissioner_vendor_photo.
      # 
      # by override object_name, 
      # on submit form => data in params will include: 
      # params['spree_cm_commissioner_vendor_photo']
      #
      # @overrided
      def object_name
        'spree_cm_commissioner_vendor_photo'
      end

      # @overrided
      def collection_url(options = {})
        admin_vendor_vendor_photos_url(options)
      end
    end
  end
end