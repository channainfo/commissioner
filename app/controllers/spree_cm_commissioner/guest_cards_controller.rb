module SpreeCmCommissioner
  class GuestCardsController < ApplicationController
    layout false

    def show
      guest = SpreeCmCommissioner::Guest.find_by!(token: params[:id])

      # Cache the response
      cache_key = "#{guest.id}-#{guest.updated_at}-#{guest.line_item.variant.guest_card_classes.first.updated_at}"

      Rails.cache.fetch(cache_key, expires_in: 12.hours) do
        render(
          template: 'spree_cm_commissioner/guest_cards/show',
          locals: guest_card_locals(guest)
        )
      end
    end

    # TODO: render in PNG when url is end with .jpg using 'imgkit'
    # def render_jpg
    #   html = render_to_string(
    #     template: 'spree_cm_commissioner/guest_cards/show',
    #     locals: {
    #       banner_url: banner_url,
    #       qr_url: guest_qr,
    #       event_date: event_date,
    #       venue: venue,
    #       ticket_type: ticket_type,
    #       seat_number: seat_number
    #     }
    #   )

    #   kit = IMGKit.new(html, quality: 100, width: 400)
    #   image_data = kit.to_jpg

    #   send_data image_data, type: 'image/jpeg', disposition: 'inline'
    # end

    private

    def guest_card_locals(guest)
      {
        banner_src: banner_src(guest),
        logo_src: logo_src(guest),
        guest_qr_data: guest.token,
        event_date: event_date(guest),
        venue: venue(guest),
        ticket_type: guest.line_item.name,
        seat_number: seat_number(guest),
        full_name: full_name(guest),
        phone_number: phone_number(guest)
      }
    end

    def banner_src(guest)
      cdn_image_url(guest.line_item.variant.guest_card_classes.first!.background_image.attachment)
    end

    def logo_src(guest)
      cdn_image_url(guest.line_item.vendor.logo.attachment)
    end

    def event_date(guest)
      guest.line_item.from_date.strftime('%d %b %Y | %I%p')
    end

    def venue(guest)
      guest.line_item.product.venue.place.name || 'N/A'
    end

    def seat_number(guest)
      guest.seat_number || guest.formatted_bib_number || 'N/A'
    end

    def full_name(guest)
      guest.first_name.present? || guest.last_name.present? ? "#{guest.first_name} #{guest.last_name}" : 'N/A'
    end

    def phone_number(guest)
      if guest.phone_number.present?
        "#{guest.phone_number[0...-3]}***"
      else
        'N/A'
      end
    end
  end
end
