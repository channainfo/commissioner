module Spree
  module Api
    module V2
      module Platform
        class SeatNumberLayoutsController < ResourceController
          # override
          def index
            render_serialized_payload do
              collection_serializer.new(collection).serializable_hash
            end
          end

          # override
          def collection
            guest = SpreeCmCommissioner::Guest.find(params[:guest_id])
            event_id = guest.event.id

            reserved_seats = SpreeCmCommissioner::Guest
                             .where(event_id: event_id)
                             .where.not(seat_number: nil)
                             .pluck(:seat_number)

            seat_layouts = guest.variant.seat_number_layouts

            # Subtract guest seat numbers from seat layouts
            available_seat_layouts = seat_layouts - reserved_seats

            # Generate the final list of seat structs
            available_seat_layouts.map { |seat| seat_struct(seat) }
          end

          def model_class
            SpreeCmCommissioner::Guest
          end

          def resource_serializer
            ::SpreeCmCommissioner::Api::V2::Platform::SeatNumberLayoutsSerializer
          end

          private

          def seat_struct(seat)
            Struct.new(:id, :name).new(id: seat, name: seat)
          end
        end
      end
    end
  end
end
