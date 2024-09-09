module Spree
  module Admin
    class ProductPlacesController < Spree::Admin::ResourceController
      belongs_to 'spree/product', find_by: :slug

      before_action :load_product
      before_action :load_places
      before_action :load_product_places, only: %i[edit update new]

      def index
        @product_places = filter_product_places(params[:type])
      end

      def new
        @product_place = SpreeCmCommissioner::ProductPlace.new(product_id: @product.id, checkinable_distance: 100)
      end

      def create
        @product_place = SpreeCmCommissioner::ProductPlace.new(permitted_resource_params)
        @product_place.product = parent

        if @product_place.place_id.blank?
          flash[:error] = I18n.t('product_place.place_required')
          render :new, status: :unprocessable_entity
          return
        end

        begin
          if @product_place.save
            flash[:success] = I18n.t('product_place.created_successfully')
            redirect_to collection_url
          else
            flash[:error] = @product_place.errors.full_messages.join(', ')
            render :new
          end
        rescue ActiveRecord::RecordNotUnique
          flash[:error] = I18n.t('product_place.already_exist')
          render :new, status: :unprocessable_entity
        end
      end

      def destroy
        @product_place = SpreeCmCommissioner::ProductPlace.find(params[:id])

        if @product_place.destroy
          flash[:success] = Spree.t('product_place.deleted_successfully')
        else
          flash[:error] = @product_place.errors.full_messages.join(', ')
        end

        redirect_to collection_url
      end

      def update_positions
        params[:positions].each do |id, index|
          product_place = SpreeCmCommissioner::ProductPlace.find(id)
          product_place.update(position: index)
        end
      end

      private

      def filter_product_places(type)
        if type.present?
          parent.product_places.where(type: SpreeCmCommissioner::ProductPlace.types[type])
        else
          parent.product_places
        end
      end

      def load_product
        @product ||= Spree::Product.find_by(slug: params[:product_id])
      end

      def load_places
        @places = parent.vendor.places
      end

      def load_product_places
        @product_places = parent.product_places || []
      end

      # override
      def load_resource
        @object = parent.product_places
      end

      # override
      def collection_url
        admin_product_product_places_path(parent)
      end

      # override
      def model_class
        SpreeCmCommissioner::ProductPlace
      end

      # override
      def permitted_resource_params
        params.require(:spree_cm_commissioner_product_place).permit(:place_id, :checkinable_distance, :type)
      end
    end
  end
end
