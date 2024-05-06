module Spree
  module Events
    class GuestsController < Spree::Events::BaseController
      helper SpreeCmCommissioner::Admin::GuestHelper

      def collection_url
        event_guests_url
      end

      def model_class
        SpreeCmCommissioner::Guest
      end

      def check_in
        guest_ids = [params[:id]]
        context = SpreeCmCommissioner::CheckInBulkCreator.call(
          guest_ids: guest_ids,
          check_in_by: spree_current_user
        )

        if context.success?
          flash[:success] = Spree.t('event.check_in.success')
        else
          flash[:error] = context.message.to_s.titleize
        end

        redirect_to edit_object_url
      end

      def uncheck_in
        guest_ids = [params[:id]]
        context = SpreeCmCommissioner::CheckInDestroyer.call(
          guest_ids: guest_ids,
          destroyed_by: spree_current_user
        )

        if context.success?
          flash[:success] = Spree.t('event.uncheck_in.success')
        else
          flash[:error] = context.message.to_s.titleize
        end

        redirect_to edit_object_url
      end

      def edit
        @check_in = @guest.check_in
        @event = @guest.event
      end

      # override
      def edit_object_url
        edit_event_guest_url
      end

      def send_email
        @guest = SpreeCmCommissioner::Guest.find(params[:id])
        @event = @guest.event

        @email = params[:guest][:email]

        Spree::OrderMailer.ticket_email(@guest, @email).deliver_later

        flash[:success] = 'Email sent successfully' # rubocop:disable Rails/I18nLocaleTexts
        redirect_to event_guest_path
      end

      # POST: /guests/generate_guest_csv
      def generate_guest_csv
        name = "guest-csv#{Time.current.to_i}"
        file_name = "guests-data-#{current_event.name.gsub(' ', '-')}-#{Time.current.to_i}.csv"
        file_path = Rails.root.join('tmp', file_name)
        export_type = SpreeCmCommissioner::Exports::ExportGuestCsv

        guest_csv = SpreeCmCommissioner::Exports::ExportGuestCsv.new(
          name: name,
          file_name: file_name,
          file_path: file_path,
          export_type: export_type,
          preferred_event_id: current_event.id
        )

        if guest_csv.save
          flash[:success] = Spree.t('csv.csv_generate')
          redirect_to event_data_exports_path
        else
          flash[:error] = Spree.t('csv.generate_error')
          redirect_back(fallback_location: event_guests_path)
        end
      end

      private

      def permitted_resource_params
        params.required(:spree_cm_commissioner_guest).permit(:entry_type)
      end

      def collection
        scope = model_class.where(event_id: current_event&.id)

        @search = scope.ransack(params[:q])
        @collection = @search.result
                             .includes(:id_card)
                             .page(params[:page])
                             .per(params[:per_page])
      end

      def collection_actions
        super << :generate_guest_csv
      end
    end
  end
end
