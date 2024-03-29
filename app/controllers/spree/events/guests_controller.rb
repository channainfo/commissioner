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

      def index
        file_name = Rails.root.join('tmp', csv_name)

        respond_with(collection) do |format|
          format.csv do
            SpreeCmCommissioner::GenerateGuestsCsv.call(
              collection: collection,
              file_name: file_name
            )

            send_file file_name
          end
        end
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
        @guest = SpreeCmCommissioner::Guest.find(params[:id])
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

      private

      def csv_name
        @csv_name ||= "guests-data-#{current_event.name.downcase.gsub(' ', '-')}-#{Time.current.to_i}.csv"
      end

      def permitted_resource_params
        params.required(:spree_cm_commissioner_guest).permit(:entry_type)
      end

      def collection
        scope = model_class.where(event_id: current_event.id)

        @search = scope.ransack(params[:q])
        @collection = @search.result
                             .includes(:id_card)
                             .page(params[:page])
                             .per(params[:per_page])
      end
    end
  end
end
