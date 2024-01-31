module SpreeCmCommissioner
  class Guest < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::KycBitwise

    delegate :kyc, to: :line_item

    enum gender: { :other => 0, :male => 1, :female => 2 }

    belongs_to :line_item, class_name: 'Spree::LineItem', optional: false
    belongs_to :occupation, class_name: 'Spree::Taxon'

    has_one :id_card, class_name: 'SpreeCmCommissioner::IdCard', dependent: :destroy
    has_one :check_in, class_name: 'SpreeCmCommissioner::CheckIn'

    validate :validate_kyc_fields, if: :kyc?

    def validate_kyc_fields
      BIT_FIELDS.each do |field, bit_value|
        next unless kyc_value_enabled?(bit_value)
        next if kyc_value_validated_for?(field)

        errors.add(field, 'must_fill_info')
      end
    end

    def kyc_value_validated_for?(field)
      return (first_name.present? || last_name.present?) if field == :guest_name
      return gender.present? if field == :guest_gender
      return dob.present? if field == :guest_dob
      return occupation.present? if field == :guest_occupation
      return id_card.present? if field == :guest_id_card

      false
    end

    def generate_svg_qr
      qrcode = RQRCode::QRCode.new(qr_data)
      qrcode.as_svg(
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 5,
        standalone: true,
        use_path: true,
        viewbox: '0 0 20 10'
      )
    end

    def generate_png_qr(size = 120)
      qrcode = RQRCode::QRCode.new(qr_data)
      qrcode.as_png(
        bit_depth: 1,
        border_modules: 1,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil,
        fill: 'white',
        module_px_size: 4,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: size
      )
    end

    def qr_data
      if id && line_item_id && line_item&.order_id
        "#{id}-#{line_item_id}-#{line_item.order_id}"
      else
        'INVALID'
      end
    end
  end
end
