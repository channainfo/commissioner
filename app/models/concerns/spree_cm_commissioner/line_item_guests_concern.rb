module SpreeCmCommissioner
  module LineItemGuestsConcern
    extend ActiveSupport::Concern

    included do
      validate :validate_total_adults, if: -> { public_metadata[:number_of_adults].present? }
      validate :validate_total_kids, if: -> { public_metadata[:number_of_kids].present? }
    end

    def remaining_total_guests = [number_of_guests - guests.size, 0].max
    def number_of_guests = number_of_adults + number_of_kids

    def allowed_extra_adults = variant.allowed_extra_adults * quantity
    def allowed_extra_kids = variant.allowed_extra_kids * quantity

    def allowed_total_adults = (variant.number_of_adults * quantity) + allowed_extra_adults
    def allowed_total_kids = (variant.number_of_kids * quantity) + allowed_extra_kids

    def number_of_adults = public_metadata[:number_of_adults] || (variant.number_of_adults * quantity)
    def number_of_kids = public_metadata[:number_of_kids] || (variant.number_of_kids * quantity)

    def generate_remaining_guests
      return if remaining_total_guests.zero?

      remaining_total_guests.times do
        guests.create!
      end
    end

    def extra_adults
      return 0 unless extra_adults?

      public_metadata[:number_of_adults] - (variant.number_of_adults * quantity)
    end

    def extra_kids
      return 0 unless extra_kids?

      public_metadata[:number_of_kids] - (variant.number_of_kids * quantity)
    end

    def guest_options
      @guest_options ||= {
        remaining_total_guests: remaining_total_guests,
        number_of_guests: number_of_guests,
        allowed_extra_adults: allowed_extra_adults,
        allowed_extra_kids: allowed_extra_kids,
        allowed_total_adults: allowed_total_adults,
        allowed_total_kids: allowed_total_kids,
        number_of_adults: number_of_adults,
        number_of_kids: number_of_kids,
        extra_adults: extra_adults,
        extra_kids: extra_kids
      }
    end

    def extra_adults?
      public_metadata[:number_of_adults].present? && public_metadata[:number_of_adults] > variant.number_of_adults * quantity
    end

    def extra_kids?
      public_metadata[:number_of_kids].present? && public_metadata[:number_of_kids] > variant.number_of_kids * quantity
    end

    private

    def validate_total_adults
      return if public_metadata[:number_of_adults] <= allowed_total_adults

      errors.add(:quantity, 'exceed_total_adults')
    end

    def validate_total_kids
      return if public_metadata[:number_of_kids] <= allowed_total_kids

      errors.add(:quantity, 'exceed_total_kids')
    end
  end
end
