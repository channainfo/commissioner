module Spree
  module Billing
    class VendorsController < Spree::Billing::BaseController
      before_action :build_logo, only: %i[create update]
      before_action :build_qrcode, only: %i[create update]

      def create
        @vendor.build_image(attachment: permitted_resource_params.delete(:image)) if permitted_resource_params[:image]
        super
      end

      def update
        @vendor.create_image(attachment: permitted_resource_params.delete(:image)) if permitted_resource_params[:image]
        format_translations if defined? SpreeGlobalize
        super
      end

      def update_positions
        params[:positions].each do |id, position|
          vendor = Spree::Vendor.find(id)
          vendor.set_list_position(position)
        end

        respond_to do |format|
          format.js { render plain: 'Ok' }
        end
      end

      private

      def find_resource
        Vendor.with_deleted.friendly.find(params[:id])
      end

      def collection
        params[:q] = {} if params[:q].blank?
        vendors = super.order(priority: :asc)
        @search = vendors.ransack(params[:q])

        @collection = @search.result
                             .includes(vendor_includes)
                             .page(params[:page])
                             .per(params[:per_page])
      end

      def vendor_includes
        {
          image: [],
          products: []
        }
      end

      def format_translations
        return if params[:vendor][:translations_attributes].blank?

        params[:vendor][:translations_attributes].each do |_, data|
          translation = @vendor.translations.find_or_create_by(locale: data[:locale])
          translation.name = data[:name]
          translation.about_us = data[:about_us]
          translation.contact_us = data[:contact_us]
          translation.slug = data[:slug]
          translation.save!
        end
      end

      def build_logo
        return unless permitted_resource_params[:logo]

        @vendor.build_logo(attachment: permitted_resource_params.delete(:logo))
      end

      def build_qrcode
        return unless permitted_resource_params[:qrcode]

        @vendor.build_qrcode(attachment: permitted_resource_params.delete(:qrcode))
      end

      def location_after_save
        edit_billing_vendor_url(@current_vendor.id)
      end
    end
  end
end
