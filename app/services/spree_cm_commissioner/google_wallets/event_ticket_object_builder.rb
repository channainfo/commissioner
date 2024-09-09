module SpreeCmCommissioner
  module GoogleWallets
    class EventTicketObjectBuilder < BaseObjectBuilder
      # override
      def object
        {
          iss: iss,
          aud: 'google',
          typ: 'savetowallet',
          payload: {
            eventTicketObjects: [
              {
                id: ticket_id,
                classId: ticket_class_id,
                ticketHolderName: ticket_holder_name,
                ticketNumber: ticket_number,
                ticketType: {
                  defaultValue: {
                    language: 'en-US',
                    value: ticket_name
                  }
                },
                state: 'ACTIVE',
                barcode: {
                  type: 'QR_CODE',
                  value: line_item.qr_data,
                  alternateText: 'QR Code'
                },
                linksModuleData: {
                  uris: [
                    {
                      uri: ticket_detail_url,
                      description: 'Visit Ticket Detail'
                    }
                  ]
                },
                textModulesData: [
                  {
                    header: 'Ticket Quantities',
                    body: line_item.quantity
                  },
                  {
                    header: 'Option Texts',
                    body: line_item.options_text
                  }
                ]
              }
            ]
          }
        }
      end

      def ticket_name
        line_item.name
      end

      def ticket_number
        line_item.number
      end

      def ticket_id
        "#{issuer_id}.#{line_item.id}"
      end

      def ticket_class_id
        "#{issuer_id}.#{line_item.google_wallet.class_id}"
      end

      def ticket_holder_name
        line_item.order.customer_address.full_name
      end

      def ticket_detail_url
        "https://#{Spree::Store.default.url}/bookings/#{line_item.order.number}/tickets/#{line_item.id}"
      end
    end
  end
end
