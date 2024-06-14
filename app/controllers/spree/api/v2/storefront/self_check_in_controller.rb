module Spree
  module Api
    module V2
      module Storefront
        class SelfCheckInController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user
          before_action :load_operator, only: [:create]

          rescue_from JWT::ExpiredSignature, with: :expired_signature
          rescue_from JWT::VerificationError, with: :verification
          rescue_from JWT::DecodeError, with: :decode_error

          # override
          def create
            spree_authorize! :create, model_class
            validate_token!(params[:qr_data])

            context = create_check_in_records(params[:guest_ids])

            if context.success?
              render_serialized_payload(201) do
                collection_serializer.new(
                  context.check_ins, { include: resource_includes }
                ).serializable_hash
              end
            else
              render_error_payload(context.message)
            end
          end

          private

          def create_check_in_records(guest_ids)
            SpreeCmCommissioner::CheckInBulkCreator.call(
              guest_ids: guest_ids,
              check_in_by: spree_current_user
            )
          end

          LEEWAY_IN_SECONDS = 60
          def validate_token!(qr_data)
            JWT.decode(qr_data, @operator&.secure_token, true, { algorithm: 'HS256', leeway: LEEWAY_IN_SECONDS })
          end

          def expired_signature(exception)
            render_error_payload(exception.message, 400)
          end

          def verification(exception)
            render_error_payload(exception.message, 400)
          end

          def decode_error(exception)
            render_error_payload(exception.message, 400)
          end

          def load_operator
            @operator = Spree::User.find_by(id: params[:operator_id])
          end

          # override
          def model_class
            SpreeCmCommissioner::CheckIn
          end

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Operator::CheckInSerializer
          end

          # override
          def collection_serializer
            SpreeCmCommissioner::V2::Operator::CheckInSerializer
          end
        end
      end
    end
  end
end
