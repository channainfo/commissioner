module Spree
  module Api
    module V2
      module Storefront
        class GooglePaysController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def create
            result = SpreeCmCommissioner::GooglePayRequestObjectContructor.call
            if result.success?
              render_serialized_payload(201) do
                {
                  data: {
                    id: id,
                    type: 'google_pay',
                    attributes: {
                      token: result.token
                    }
                  }
                }
              end
            else
              render json: { error: result.error }, status: :unprocessable_entity
            end
          end

          def id
            SecureRandom.hex
          end
        end
      end
    end
  end
end
