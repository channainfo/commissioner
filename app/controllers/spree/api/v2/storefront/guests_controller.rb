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

          # show by guest token
          def show
            guest = model_class.find_by(token: params[:id])

            if guest
              render_serialized_payload { serialize_resource(guest) }
            else
              render_error_payload({ error: 'Guest not found' }, 404)
            end
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
            resource = parent.guests.create(guest_params)

            if resource.save
              render_serialized_payload(201) { serialize_resource(resource) }
            else
              render_error_payload(resource.errors, 400)
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
            parent.guests
          end

          def parent
            @parent ||= if spree_current_user.nil?
                          Spree::LineItem.find(params[:line_item_id])
                        else
                          spree_current_user.line_items.find(params[:line_item_id])
                        end
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
