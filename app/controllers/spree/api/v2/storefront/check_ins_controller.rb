module Spree
  module Api
    module V2
      module Storefront
        class CheckInsController < Spree::Api::V2::ResourceController
          before_action :require_spree_current_user, only: %i[index show update destroy]

          def show
            spree_authorize! :show, resource
            super
          end

          def create
            spree_authorize! :create, SpreeCmCommissioner::CheckIn

            check_in = spree_current_user.check_ins.build(check_in_attributes)

            if check_in.save
              render_serialized_payload { serialize_resource(check_in) }
            else
              render_error_payload(check_in.errors.full_messages.to_sentence)
            end
          end

          private

          def check_in_attributes
            qr_data = params[:qr_data]
            data_array = qr_data.split('-')

            attributes = {}

            attributes[:guest_id] = data_array[0]
            attributes[:line_item_id] = data_array[1]
            attributes[:order_id] = data_array[2]

            attributes
          end

          def model_class
            SpreeCmCommissioner::CheckIn
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::CheckInSerializer
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::CheckInSerializer
          end
        end
      end
    end
  end
end
