module Spree
  module Api
    module V2
      module Storefront
        class CheckInRecordsController < Spree::Api::V2::ResourceController
          before_action :require_spree_current_user, only: %i[index show update destroy]

          def show
            spree_authorize! :show, resource
            super
          end

          def create
            spree_authorize! :create, SpreeCmCommissioner::CheckInRecord

            # create by QR code
            # @check_in_record = spree_current_user.check_in_records.new(check_in_record_attributes)

            # create by Postman
            @check_in_record = spree_current_user.check_in_records.new(check_in_record_params)

            if @check_in_record.save
              render_serialized_payload { serialize_resource(@check_in_record) }
            else
              render_error_payload(@check_in_record.errors.full_messages.to_sentence)
            end
          end

          def update
            @check_in_record = spree_current_user.check_in_records.find(params[:id])
            spree_authorize! :update, @check_in_record

            if @check_in_record.update(check_in_record_params)
              render_serialized_payload { serialize_resource(@check_in_record) }
            else
              render_error_payload(@check_in_record.errors.full_messages.to_sentence)
            end
          end

          def destroy
            @check_in_record = spree_current_user.check_in_records.find(params[:id])
            spree_authorize! :destroy, @check_in_record

            if @check_in_record.destroy
              head :no_content
            else
              render_error_payload('Error destroying check_in record')
            end
          end

          private

          def check_in_record_attributes
            # byebug

            qr_data = params[:qr_data]
            data_array = qr_data.split('-')

            attributes = {}

            attributes[:order_id] = data_array[2]
            attributes[:line_item_id] = data_array[1]
            attributes[:guest_id] = data_array[0]

            attributes
          end

          def model_class
            SpreeCmCommissioner::CheckInRecord
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::CheckInRecordSerializer
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::CheckInRecordSerializer
          end

          def check_in_record_params
            params.require(:check_in_record).permit(:order_id, :line_item_id, :guest_id)
          end
        end
      end
    end
  end
end
