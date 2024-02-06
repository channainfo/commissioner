module Spree
  module Api
    module V2
      module Storefront
        module Account
          class PreferredPaymentMethodController < ::Spree::Api::V2::ResourceController
            before_action :require_spree_current_user

            # override
            def update
              spree_current_user.preferred_payment_method_id = resource.id

              if spree_current_user.save
                render_serialized_payload { serialize_resource(resource) }
              else
                render_error_payload(resource.errors.full_messages.to_sentence)
              end
            end

            # override
            def resource
              Spree::PaymentMethod.find(params[:payment_method_id])
            end

            # override
            def resource_serializer
              Spree::V2::Storefront::PaymentMethodSerializer
            end
          end
        end
      end
    end
  end
end
