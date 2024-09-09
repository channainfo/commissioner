module SpreeCmCommissioner
  class BibNumberSwapper < BaseInteractor
    delegate :guests, :current_guest, :target_guest, to: :context

    def call
      swap_guest_bib_number
    end

    private

    def swap_guest_bib_number
      ActiveRecord::Base.transaction do
        current_bib_number = current_guest.bib_number
        current_bib_index = current_guest.bib_index
        current_bib_seat_number = current_guest.seat_number

        target_bib_number = target_guest.bib_number
        target_bib_index = target_guest.bib_index
        target_bib_seat_number = target_guest.seat_number

        target_guest.update!(bib_number: nil, bib_index: nil, seat_number: nil)
        current_guest.update!(bib_number: target_bib_number, bib_index: target_bib_index, seat_number: target_bib_seat_number)
        target_guest.update!(bib_number: current_bib_number, bib_index: current_bib_index, seat_number: current_bib_seat_number)
      end
    end
  end
end
