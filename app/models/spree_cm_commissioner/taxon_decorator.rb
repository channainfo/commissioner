module SpreeCmCommissioner
  module TaxonDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::TaxonKind

      base.preference :background_color, :string
      base.preference :foreground_color, :string

      base.has_many :taxon_vendors, class_name: 'SpreeCmCommissioner::TaxonVendor'
      base.has_many :vendors, through: :taxon_vendors

      base.has_many :guest_card_classes, class_name: 'SpreeCmCommissioner::GuestCardClass'
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

      base.has_many :visible_classifications, -> { where(visible: true).order(:position) }, class_name: 'Spree::Classification'
      base.has_many :visible_products, through: :visible_classifications, class_name: 'Spree::Product', source: :product

      base.validates_associated :category_icon
      base.before_save :set_kind
      base.before_save :set_slug

      base.whitelisted_ransackable_attributes |= %w[kind]

      base.enum purchasable_on: { both: 0, web: 1, app: 2 }
    end

    def background_color
      preferred_background_color
    end

    def foreground_color
      preferred_foreground_color
    end

    def set_kind
      self.kind = taxonomy.kind
    end

    def set_slug
      self.slug = permalink&.parameterize
    end
  end
end

Spree::Taxon.prepend(SpreeCmCommissioner::TaxonDecorator) unless Spree::Taxon.included_modules.include?(SpreeCmCommissioner::TaxonDecorator)
