module Spree
  module Api
    module V2
      module Storefront
        class GuestsController < ::Spree::Api::V2::ResourceController
          # override
          def model_class
            SpreeCmCommissioner::Guest
          end

          # override
          def collection
            model_class.all
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
            resource = line_item.guests.create(guest_params)

            if resource.save
              render_serialized_payload(201) { serialize_resource(resource) }
            else
              render_error_payload(context, 400)
            end
          end

          def update
            resource.assign_attributes(guest_params)

            if resource.save
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource, 400)
            end
          end

          private

          # override
          def scope
            line_item.guests
          end

          def line_item
            @line_item ||= spree_current_user.line_items.find(params[:line_item_id])
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
