module Spree
  module Transit
    class TripsController < Spree::Transit::BaseController
      before_action :load_route, only: [:index, :new, :create, :edit]
      before_action :load_vendor
      before_action :load_resource_instance, only: [:new]
      before_action :new_stop_time, only: [:new]


      helper 'spree_cm_commissioner/transit/trip_status'

      def load_route
        @route ||= Spree::Product.find_by!(id: params[:route_id])
      end

      def scope
        load_route
        @route.variants
      end

      def new_stop_time
        @variant.stop_times.build
      end

      def public_status
        if @object.update(status: !@object.status)
          flash[:success] = flash_message_for(@object, :successfully_updated)
        else
          flash[:error] = @object.errors.full_messages.to_sentence
        end

        redirect_to transit_route_trips_url
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.message
        redirect_to transit_route_trips_url
      end

      def load_vendor
        @vendor ||= vendors.find { |v| v[:slug] == session[:transit_current_vendor_slug] } || vendors.first
      end

      def collection

        return @collection if @collection.present?

        params[:q] ||= {}
        params[:q][:deleted_at_null] ||= '1'
        params[:q][:status_eq] ||= 'published' unless params[:q].blank?
        params[:q][:status_eq] == "published" ? true : false

        @collection = scope

        if params[:q].present?
          if params[:q][:status_eq] == "published"
            @collection = @collection.where(status: true)
          else
            @collection = @collection.where(status: false)
          end
        end

        if params[:q][:deleted_at_null] == '0'
          @collection = @collection.with_deleted
        end

        @search = @collection.ransack(params[:q].reject { |k, _v| k.to_s == 'deleted_at_null' })
        @collection = @search.result.
                      page(params[:page]).
                      per(params[:per_page] || Spree::Backend::Config[:variants_per_page])

        @collection
      end

      def load_resource_instance
        return scope.new if new_actions.include?(action)
        scope.find_by!(id: params[:id])
      end

      def location_after_save
       transit_route_trips_url
      end

      def model_class
        Spree::Variant
      end

      def object_name
        'variant'
      end

    end
  end
end
