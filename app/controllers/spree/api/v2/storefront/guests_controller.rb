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

            if params[:template_guest_id].present?
              template_guest = SpreeCmCommissioner::TemplateGuest.find(params[:template_guest_id])
              update_with_template_guest(template_guest)
            else
              update_without_template_guest
            end
          end

          private

          def update_with_template_guest(template_guest)
            if resource.update(merged_guest_params(template_guest))
              if template_guest.id_card.present?
                duplicate_id_card(template_guest)
              else
                render_serialized_payload { serialize_resource(resource) }
              end
            else
              render_error_payload(resource.errors, 400)
            end
          end

          def update_without_template_guest
            if resource.update(guest_params)
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource.errors, 400)
            end
          end

          def duplicate_id_card(template_guest)
            result = SpreeCmCommissioner::IdCardDuplicator.call(guest: resource, template_guest: template_guest)

            if result.success?
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(result.message, 400)
            end
          end

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
        end
      end
    end
  end
end
