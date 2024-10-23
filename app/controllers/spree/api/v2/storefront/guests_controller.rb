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

            resource = if params[:template_guest_id].present?
                         scope.new(merged_guest_params(template_guest))
                       else
                         scope.new(guest_params)
                       end

            if resource.save
              render_serialized_payload(201) { serialize_resource(resource) }
            else
              render_error_payload(resource.errors, 400)
            end
          end

          def update
            spree_authorize! :update, spree_current_order, order_token

            if params[:template_guest_id].present?
              if resource.update(merged_guest_params(template_guest))
                render_serialized_payload { serialize_resource(resource) }
              else
                render_error_payload(resource.errors, 400)
              end
            elsif resource.update(guest_params)
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource.errors, 400)
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
              :upload_later,
              :template_guest_id
            )
          end

          def merged_guest_params(template_guest)
            # Fetch guest params and merge template guest attributes (excluding certain fields)
            guest_params.merge(template_guest.attributes.except('id', 'created_at', 'updated_at', 'is_default', 'deleted_at'))
          end

          def template_guest
            SpreeCmCommissioner::TemplateGuest.find(params[:template_guest_id])
          end
        end
      end
    end
  end
end
