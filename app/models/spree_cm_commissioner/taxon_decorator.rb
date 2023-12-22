module SpreeCmCommissioner
  module TaxonDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::TaxonKind

      base.has_one :category_icon, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::TaxonCategoryIcon'

      base.has_one :web_banner, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::TaxonWebBanner'
      base.has_one :app_banner, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::TaxonAppBanner'

      base.validates_associated :category_icon
      base.before_save :set_kind
    end

    def set_kind
      self.kind = taxonomy.kind
    end
  end
end

Spree::Taxon.prepend(SpreeCmCommissioner::TaxonDecorator) unless Spree::Taxon.included_modules.include?(SpreeCmCommissioner::TaxonDecorator)
