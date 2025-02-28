module Spree
  module Api
    module V2
      module Storefront
        class SelfCheckInController < ::Spree::Api::V2::ResourceController
          LEEWAY_IN_SECONDS = 120

          before_action :require_spree_current_user
          before_action :load_operator, only: [:create]

          rescue_from JWT::ExpiredSignature, with: :expired_signature
          rescue_from JWT::VerificationError, with: :verification
          rescue_from JWT::DecodeError, with: :decode_error

          # override
          def create
            validate_token!(params[:qr_data])

            unless invalid_line_item(params[:line_item_id], params[:event_id])
              render_error_payload(I18n.t('self_check_in.invalid_line_item'), 400)
              return
            end

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
              check_ins_attributes: guest_ids.map { |guest_id| { guest_id: guest_id } },
              check_in_by: @operator
            )
          end

          def validate_token!(qr_data)
            JWT.decode(qr_data, @operator.secure_token, true, { algorithm: 'HS256', leeway: LEEWAY_IN_SECONDS })
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
            @operator = Spree::User.find(params[:operator_id])
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

          def invalid_line_item(line_item_id, event_id)
            line_item = Spree::LineItem.find(line_item_id)
            taxon = Spree::Taxon.find(event_id)

            vendor_match = taxon.vendors.exists?(id: line_item.product.vendor_id)
            taxons_match = line_item.product.taxons.to_a.intersect?(taxon.self_and_descendants.to_a)

            vendor_match && taxons_match
          end
        end
      end
    end
  end
end
