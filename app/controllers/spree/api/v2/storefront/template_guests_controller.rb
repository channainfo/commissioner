module Spree
  module Api
    module V2
      module Storefront
        class TemplateGuestsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          # override
          def model_class
            SpreeCmCommissioner::TemplateGuest
          end

          # override
          def collection
            scope = spree_current_user.template_guests
            scope = scope.where(is_default: true) if params[:is_default].present?
            scope
          end

          # override
          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::TemplateGuestSerializer
          end

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::TemplateGuestSerializer
          end

          def create
            resource = spree_current_user.template_guests.create(template_guest_params)

            if resource.save
              render_serialized_payload(201) { serialize_resource(resource) }
            else
              render_error_payload(resource.errors, 400)
            end
          end

          def update
            resource = spree_current_user.template_guests.find(params[:id])
            resource.assign_attributes(template_guest_params)

            if resource.save
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource.errors, 400)
            end
          end

          def destroy
            resource = spree_current_user.template_guests.find(params[:id])

            if resource.destroy
              render json: { message: 'Template guest deleted successfully' }, status: :ok
            else
              render_error_payload(resource.errors, 400)
            end
          end

          private

          def template_guest_params
            params.permit(
              :first_name,
              :last_name,
              :dob,
              :phone_number,
              :emergency_contact,
              :gender,
              :occupation_id,
              :other_occupation,
              :nationality_id,
              :is_default
            )
          end
        end
      end
    end
  end
end
