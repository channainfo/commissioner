module Spree
  module Transit
    class ServiceCalendarsController < Spree::Transit::BaseController
      before_action :load_vendor
      create.before :set_vendor
      update.before :set_vendor

      new_action.before :set_exception_rules

      helper 'spree_cm_commissioner/transit/service_calendars'

      def update_status
        if @object.update(active: !@object.active)
          flash[:success] = flash_message_for(@object, :successfully_updated)
        else
          flash[:error] = @object.errors.full_messages.to_sentence
        end

        redirect_to transit_vendor_service_calendars_url
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.message
        redirect_to transit_vendor_service_calendars_url
      end

      def location_after_save
        transit_vendor_service_calendars_url
      end

      protected

      def collection_url(options = {})
        transit_vendor_service_calendars_url(options)
      end

      def permitted_resource_params
        add_exception_rules_type(params[:spree_cm_commissioner_service_calendar][:exception_rules])
        service_calendar_params = params.require(:spree_cm_commissioner_service_calendar)
                                        .permit(:calendarable_id, :calendarable_type, :start_date, :end_date,
                                                :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :name, :not_available_reason,
                                                :service_type
                                        )
        service_calendar_params[:exception_rules] = build_exception_rules(params[:spree_cm_commissioner_service_calendar][:exception_rules])
        service_calendar_params
      end

      def model_class
        SpreeCmCommissioner::ServiceCalendar
      end

      def object_name
        'spree_cm_commissioner_service_calendars'
      end

      private

      def build_exception_rules(exception_rules)
        exception_rules.values.reject! { |rule| rule['from'].blank? || rule['to'].blank? } || exception_rules.values
      end

      def add_exception_rules_type(exception_rules)
        exception_rules.values.each do |rule|
          rule['type'] = 'exclusion'
        end
      end

      def set_vendor
        @object.calendarable_type = calendarable_type
        @object.calendarable_id   = calendarable_id
      end

      def load_vendor
        @vendor ||= vendors.find { |v| v[:slug] == session[:transit_current_vendor_slug] } || vendors.first
      end

      def collection
        load_vendor

        @objects = model_class.where(
          calendarable_type: calendarable_type,
          calendarable_id: calendarable_id
        ).order(id: :desc)

        @search = @objects.ransack(params[:q])
        @collection = @search.result

        @collection
      end

      def set_exception_rules
        @exception_rules = [{ from: DateTime.now, to: DateTime.now, type: 'exclusion', reason: nil }]
      end

      def build_resource
        today = Time.zone.today
        model_class.new(start_date: today,
                        exception_rules: [{ from: nil, to: nil }]
                       )
      end

      def calendarable_id
        @vendor.id
      end

      def calendarable_type
        @vendor.class.name
      end
    end
  end
end
