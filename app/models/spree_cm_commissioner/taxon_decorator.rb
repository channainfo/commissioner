module SpreeCmCommissioner
  module TaxonDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::TaxonKind

      base.has_many :taxon_vendors, class_name: 'SpreeCmCommissioner::TaxonVendor'
      base.has_many :vendors, through: :taxon_vendors

      base.has_many :homepage_section_relatables,
                    class_name: 'SpreeCmCommissioner::HomepageSectionRelatable',
                    dependent: :destroy, as: :relatable

      base.has_many :user_events, class_name: 'SpreeCmCommissioner::UserEvent'
      base.has_many :users, through: :user_events, class_name: Spree.user_class.to_s
      base.has_many :products, through: :classifications, class_name: 'Spree::Product'
      base.has_many :guests, foreign_key: :event_id, class_name: 'SpreeCmCommissioner::Guest', dependent: :nullify
      base.has_many :check_ins, as: :checkinable, class_name: 'SpreeCmCommissioner::CheckIn', dependent: :nullify
      base.has_many :customer_taxons, class_name: 'SpreeCmCommissioner::CustomerTaxon'

      base.has_one :category_icon, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::TaxonCategoryIcon'

      base.has_one :web_banner, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::TaxonWebBanner'
      base.has_one :app_banner, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::TaxonAppBanner'
      base.has_one :home_banner, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::TaxonHomeBanner'

      base.has_many :children, class_name: 'Spree::Taxon', foreign_key: :parent_id, dependent: :destroy
      base.has_many :children_classifications, through: :children, source: :classifications, class_name: 'Spree::Classification'

      base.has_many :notification_taxons, class_name: 'SpreeCmCommissioner::NotificationTaxon'
      base.has_many :customer_notifications, through: :notification_taxons, class_name: 'SpreeCmCommissioner::CustomerNotification'

      base.validates_associated :category_icon
      base.before_save :set_kind
      base.before_save :set_slug

      base.whitelisted_ransackable_attributes |= %w[kind]
    end

    def set_kind
      self.kind = taxonomy.kind
    end

    def set_slug
      self.slug = permalink&.parameterize
    end

    JwtToken = Struct.new(:id, :qr_data, :expired_at)

    def jwt_token(current_user)
      @current_user = current_user
      jwt_token = generate_jwt_token(current_user)
      decoded_token = JWT.decode(jwt_token, nil, false, leeway: jwt_token['leeway'])
      JwtToken.new(
        current_user.id,
        jwt_token,
        Time.zone.at(decoded_token[0]['exp'])
      )
    end

    def generate_jwt_token(current_user)
      exp = 5.minutes.from_now.to_i
      payload = { event_id: id.to_s, operator_id: current_user.id.to_s, exp: exp }
      secret = SecureRandom.hex(16)
      jwt = generate_jwt(payload, secret)
      save_secret_key_to_user(current_user, secret)
      jwt
    end

    def generate_jwt(payload, secret)
      JWT.encode(payload, secret, 'HS256')
    end

    def save_secret_key_to_user(current_user, secret)
      user = Spree.user_class.find(current_user.id)
      ActiveRecord::Base.connected_to(role: :writing) do
        user.update(secure_token: secret)
      end
    end
  end
end

Spree::Taxon.prepend(SpreeCmCommissioner::TaxonDecorator) unless Spree::Taxon.included_modules.include?(SpreeCmCommissioner::TaxonDecorator)
