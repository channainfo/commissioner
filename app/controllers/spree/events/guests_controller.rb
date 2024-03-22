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
        @csv_file_path = csv_file_path
        @guest_ids = collection.pluck(:id)

        respond_with(collection) do |format|
          format.csv do
            if File.exist?(session[:csv_file_path])
              context = SpreeCmCommissioner::DownloadGuestCsv.call(
                csv_file_path: session[:csv_file_path],
                generate_guest_csv_job_id: session[:generate_guest_csv_job_id]
              )

              send_file context.csv_file_path
            else
              flash[:error] = Spree.t('csv.csv_not_found')
              redirect_to collection_url
            end
          end
        end
      end

      def generate_csv
        context = SpreeCmCommissioner::GenerateGuestsCsv.call(guest_ids: params[:guest_ids], csv_file_path: params[:csv_file_path])

        flash[:notice] = Spree.t('csv.csv_generate')

        session[:generate_guest_csv_job_id] = context.generate_guest_csv_job_id
        session[:csv_file_path] = params[:csv_file_path]
      end

      def edit
        @guest = SpreeCmCommissioner::Guest.find(params[:id])
        @event = @guest.event
      end

      private

      def csv_file_path
        @csv_file_path ||= Rails.root.join('tmp', csv_file_name)
      end

      def csv_file_name
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
