module Spree
  module Api
    module V2
      module Storefront
        class GuestsController < ::Spree::Api::V2::ResourceController
          include OrderConcern

          # raise 404 when no order
          before_action :ensure_order

          # override
          def model_class
            SpreeCmCommissioner::Guest
          end

          # override
          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::GuestSerializer
          end

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::GuestSerializer
          end

          def create
            spree_authorize! :update, spree_current_order, order_token

            resource = scope.new(guest_params)

            if resource.save
              render_serialized_payload(201) { serialize_resource(resource) }
            else
              render_error_payload(resource.errors, 400)
            end
          end

          def update
            spree_authorize! :update, spree_current_order, order_token

            if resource.update(guest_params)
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource, 400)
            end
          end

          private

          # override
          def scope
            parent.guests
          end

          def parent
            @parent ||= spree_current_order.line_items.find(params[:line_item_id])
          end

          def guest_params
            params.permit(
              :first_name,
              :last_name,
              :dob,
              :gender,
              :occupation_id,
              :nationality_id,
              :other_occupation,
              :social_contact,
              :social_contact_platform,
              :age,
              :emergency_contact,
              :phone_number,
              :address,
              :other_organization,
              :expectation,
              :upload_later
            )
          end
        end
      end
    end
  end
end
