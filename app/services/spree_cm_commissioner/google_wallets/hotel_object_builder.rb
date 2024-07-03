module SpreeCmCommissioner
  module GoogleWallets
    class HotelObjectBuilder < BaseGenericObjectBuilder
      # override
      def object
        {
          iss: iss,
          aud: 'google',
          typ: 'savetowallet',
          payload: {
            genericObjects: [
              {
                id: hotel_id,
                classId: hotel_class_id,
                cardTitle: {
                  defaultValue: {
                    language: 'en-US',
                    value: hotel_name
                  }
                },
                subheader: {
                  defaultValue: {
                    language: 'en-US',
                    value: hotel_line_item_number
                  }
                },
                header: {
                  defaultValue: {
                    language: 'en-US',
                    value: hotel_holder_name
                  }
                },
                textModulesData: [
                  {
                    id: 'from_date',
                    header: 'From Date',
                    body: check_in_date
                  },
                  {
                    id: 'to_date',
                    header: 'To Date',
                    body: check_out_date
                  }
                ],
                barcode: {
                  type: 'QR_CODE',
                  value: line_item.qr_data,
                  alternateText: 'QR Code'
                },
                logo: {
                  sourceUri: {
                    uri: line_item.vendor.logo.original_url
                  }
                },
                heroImage: {
                  sourceUri: {
                    uri: line_item.variant.images.first.original_url
                  }
                },
                hexBackgroundColor: '#FFFFFF'
              }
            ]
          }
        }
      end

      def hotel_id
        "#{issuer_id}.#{line_item.id}"
      end

      def hotel_class_id
        "#{issuer_id}.#{line_item.google_wallet.class_id}"
      end

      def hotel_holder_name
        line_item.order.customer_address.full_name
      end

      def hotel_name
        line_item.name
      end

      def hotel_line_item_number
        line_item.number
      end

      def hotel_address
        line_item.address
      end

      def check_in_date
        line_item.from_date
      end

      def check_out_date
        line_item.to_date
      end
    end
  end
end
