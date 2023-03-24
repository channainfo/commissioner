module Spree
  module Admin
    class VendorServiceCalendarsController < Spree::Admin::ResourceController
      before_action :load_vendor
      new_action.before :set_exception_rules

      create.before :set_vendor
      update.before :set_vendor

      helper 'spree_cm_commissioner/admin/service_calendars'

      def update_status
        if @object.update(active: !@object.active)
          flash[:success] = flash_message_for(@object, :successfully_updated)
        else
          flash[:error] = @object.errors.full_messages.to_sentence
        end

        redirect_to admin_vendor_vendor_service_calendars_url
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.message
        redirect_to admin_vendor_vendor_service_calendars_url
      end

      protected

      def model_class
        SpreeCmCommissioner::ServiceCalendar
      end

      def object_name
        'spree_cm_commissioner_service_calendars'
      end

      def collection_url(options = {})
        admin_vendor_vendor_service_calendars_url(options)
      end

      def permitted_resource_params
        service_calendar_params = params.require(:spree_cm_commissioner_service_calendar)
                                        .permit(:calendarable_id, :calendarable_type, :start_date, :end_date,
                                                :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
                                        )
        service_calendar_params[:exception_rules] = build_exception_rules(params[:spree_cm_commissioner_service_calendar][:exception_rules])
        service_calendar_params
      end

      private

      def load_vendor
        @vendor ||= (Spree::Vendor.find_by(slug: params[:vendor_id]) || Spree::Vendor.find_by(id: params[:vendor_id]))
      end

      def set_vendor
        @object.calendarable_type = calendarable_type
        @object.calendarable_id   = calendarable_id
      end

      def build_exception_rules(exception_rules)
        exception_rules.values.reject! { |rule| rule['from'].blank? || rule['to'].blank? || rule['type'].blank? } || exception_rules.values
      end

      def collection
        load_vendor

        @objects = model_class.where(
          calendarable_type: calendarable_type,
          calendarable_id: calendarable_id
        )
      end

      def set_exception_rules
        @exception_rules = [{ from: DateTime.now, to: DateTime.now, type: 'exclusion', reason: nil }]
      end

      # it load before :load_vendor
      def build_resource
        today = Time.zone.today
        model_class.new(start_date: today, end_date: today.next_year(3),
                        exception_rules: [{ from: nil, to: nil, type: 'inclusion' }]
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
