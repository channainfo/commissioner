module Spree
  module Api
    module V2
      module Operator
        class CheckInBulksController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user, only: [:create]

          def create
            spree_authorize! :create, model_class

            check_ins = []

            if params[:check_ins].present?
              check_ins = process_check_ins(params[:check_ins])
            elsif params[:guest_ids].present?
              check_ins = params[:guest_ids].map { |guest_id| { guest_id: guest_id } }
            end

            context = SpreeCmCommissioner::CheckInBulkCreator.call(
              check_ins_attributes: check_ins,
              check_in_by: spree_current_user
            )

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

          def process_check_ins(check_ins_params)
            check_ins_params.map do |check_in|
              check_in.permit(
                :guest_id,
                :confirmed_at,
                guest_attributes: %i[
                  first_name
                  last_name
                  dob
                  gender
                  occupation_id
                  nationality_id
                  other_occupation
                  social_contact
                  social_contact_platform
                  age
                  emergency_contact
                  phone_number
                  address
                  other_organization
                  expectation
                  upload_later
                ]
              ).to_h
            end
          end

          def model_class
            SpreeCmCommissioner::CheckIn
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Operator::CheckInSerializer
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Operator::CheckInSerializer
          end
        end
      end
    end
  end
end
