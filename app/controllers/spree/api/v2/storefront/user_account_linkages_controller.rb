module Spree
  module Api
    module V2
      module Storefront
        class UserAccountLinkagesController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          skip_before_action :required_schema_validation!, only: %i[index destroy]

          def collection
            spree_current_user.user_identity_providers
          end

          def create
            context = SpreeCmCommissioner::AccountLinkage.call(user: spree_current_user, id_token: params[:id_token])

            if context.success?
              identity_provider = context.identity_provider
              render_serialized_payload { serialize_resource(identity_provider) }
            else
              render_error_payload(context.message)
            end
          end

          def destroy
            user_identity_provider = spree_current_user.user_identity_providers.find(params[:id])
            user_identity_provider.destroy

            render_serialized_payload { serialize_resource(user_identity_provider) }
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::UserIdentityProviderSerializer
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::UserIdentityProviderSerializer
          end

          def required_schema
            SpreeCmCommissioner::UserAccountLinkageRequestSchema
          end
        end
      end
    end
  end
end
