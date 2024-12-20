module SpreeCmCommissioner
  class Guest < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::KycBitwise

    delegate :kyc, to: :line_item, allow_nil: true
    delegate :allowed_upload_later?, to: :line_item, allow_nil: true

    enum gender: { :other => 0, :male => 1, :female => 2 }
    enum social_contact_platform: {
      :other => 0,
      :telegram => 1,
      :facebook => 2,
      :wechat => 3,
      :whatsapp => 4,
      :line => 5,
      :viber => 6
    }, _prefix: true

    scope :complete, -> { joins(:line_item).merge(Spree::LineItem.complete) }
    scope :complete_or_canceled, -> { joins(:line_item).merge(Spree::LineItem.complete_or_canceled) }
    scope :unassigned_event, -> { where(event_id: nil) }
    scope :none_bib, -> { where(bib_prefix: [nil, '']) }

    belongs_to :line_item, class_name: 'Spree::LineItem'
    has_one :variant, class_name: 'Spree::Variant', through: :line_item
    belongs_to :user, class_name: 'Spree::User'
    belongs_to :occupation, class_name: 'Spree::Taxon'
    belongs_to :nationality, class_name: 'Spree::Taxon'

    has_many :state_changes, as: :stateful, class_name: 'Spree::StateChange'

    belongs_to :event, class_name: 'Spree::Taxon'

    has_one :id_card, class_name: 'SpreeCmCommissioner::IdCard', dependent: :destroy
    has_one :check_in, class_name: 'SpreeCmCommissioner::CheckIn'

    preference :telegram_user_id, :string
    preference :telegram_user_verified_at, :string

    before_validation :set_event_id
    before_validation :assign_seat_number, if: -> { bib_number.present? }

    validates :seat_number, uniqueness: { scope: :event_id }, allow_nil: true, if: -> { event_id.present? }
    validates :bib_index, uniqueness: true, allow_nil: true

    self.whitelisted_ransackable_associations = %w[id_card event]
    self.whitelisted_ransackable_attributes = %w[first_name last_name gender occupation_id card_type]

    def self.csv_importable_columns
      %i[
        first_name last_name phone_number age dob gender address other_occupation
        entry_type nationality_id other_organization expectation emergency_contact bib_number
        preferred_telegram_user_id seat_number
      ]
    end

    # no validation for each field as we allow user to save data to model partially.
    def allowed_checkout?
      kyc_fields.all? { |field| allowed_checkout_for?(field) }
    end

    def allowed_checkout_for?(field) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      return first_name.present? && last_name.present? if field == :guest_name
      return gender.present? if field == :guest_gender
      return dob.present? if field == :guest_dob
      return occupation.present? || other_occupation.present? if field == :guest_occupation
      return nationality.present? if field == :guest_nationality
      return age.present? if field == :guest_age
      return emergency_contact.present? if field == :guest_emergency_contact
      return other_organization.present? if field == :guest_organization
      return expectation.present? if field == :guest_expectation
      return social_contact_platform.present? && social_contact.present? if field == :guest_social_contact
      return upload_later? || (id_card.present? && id_card.allowed_checkout?) if field == :guest_id_card
      return address.present? if field == :guest_address
      return phone_number.present? if field == :guest_phone_number

      false
    end

    def require_kyc_field? # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
      kyc_fields.any? do |field|
        case field
        when :guest_name
          first_name.blank? || last_name.blank?
        when :guest_gender
          gender.blank?
        when :guest_dob
          dob.blank?
        when :guest_age
          age.blank?
        when :guest_occupation
          occupation.blank? && other_occupation.blank?
        when :guest_nationality
          nationality.blank?
        when :guest_emergency_contact
          emergency_contact.blank?
        when :guest_organization
          other_organization.blank?
        when :guest_expectation
          expectation.blank?
        when :guest_social_contact
          social_contact_platform.blank? || social_contact.blank?
        when :guest_id_card
          id_card.blank?
        when :guest_address
          address.blank?
        when :guest_phone_number
          phone_number.blank?
        else
          false
        end
      end
    end

    def set_event_id
      self.event_id ||= line_item.associated_event&.id if line_item.present?
    end

    def assign_seat_number
      return if seat_number.present? # avoid reassign seat to guest

      assign_seat_number!
    end

    def assign_seat_number!
      index = bib_number - 1
      positions = line_item.variant.seat_number_positions || []

      self.seat_number = (positions[index] if index >= 0 && index < positions.size)
    end

    def full_name
      [first_name, last_name].compact_blank.join(' ')
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
      token
    end

    def current_age
      return nil if dob.nil?

      ((Time.zone.now - dob.to_time) / 1.year.seconds).floor
    end

    def bib_required?
      line_item.variant.bib_prefix.present?
    end

    def bib_display_prefix?
      line_item.variant.bib_display_prefix?
    end

    def generate_bib
      return if bib_prefix.present? || !bib_required? || event_id.blank?

      self.class.transaction do
        rows = self.class.where(event_id: event_id, bib_prefix: line_item.variant.bib_prefix).lock
        last_bib_number = rows.map(&:bib_number).max || 0

        self.bib_prefix = line_item.variant.bib_prefix
        self.bib_number = last_bib_number + 1
        self.bib_index = "#{event_id}-#{bib_prefix}-#{bib_number}"

        save!
      end
    end

    def generate_bib!
      generate_bib
    end

    # bib_number: 345, bib_prefix: 5KM, bib_zerofill: 5 => return 5KM00345
    # bib_number: 345, bib_prefix: 5KM, bib_zerofill: 2 => return 5KM345
    def formatted_bib_number
      return nil if bib_prefix.blank?
      return nil if bib_number.blank?

      filled_bib_number = bib_number.to_s.rjust(line_item.variant.bib_zerofill.to_i, '0')

      if bib_display_prefix?
        "#{bib_prefix}#{filled_bib_number}"
      else
        filled_bib_number
      end
    end
  end
end
