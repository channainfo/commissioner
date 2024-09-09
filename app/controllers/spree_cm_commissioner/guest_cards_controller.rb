module SpreeCmCommissioner
  class GuestCardsController < ApplicationController
    layout false

    def show
      guest = SpreeCmCommissioner::Guest.find_by!(token: params[:id])

      banner_src = cdn_image_url(guest.line_item.variant.guest_card_classes.first.background_image.attachment)
      guest_qr_src = "data:image/png;base64,#{Base64.encode64(guest.generate_png_qr(108).to_s).gsub("\n", '')}"
      event_date = guest.line_item.from_date.strftime('%d %b %Y | %I%p')
      venue = guest.line_item.product.venue.place.name || 'N/A'
      ticket_type = guest.line_item.name
      seat_number = guest.seat_number || guest.formatted_bib_number || 'N/A'

      render(
        template: 'spree_cm_commissioner/guest_cards/show',
        locals: {
          banner_src: banner_src,
          guest_qr_src: guest_qr_src,
          event_date: event_date,
          venue: venue,
          ticket_type: ticket_type,
          seat_number: seat_number
        }
      )
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
  end
end
