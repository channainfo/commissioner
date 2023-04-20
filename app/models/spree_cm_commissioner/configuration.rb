module SpreeCmCommissioner
  class Configuration < Spree::Preferences::Configuration
    # Some example preferences are shown below, for more information visit:
    # https://dev-docs.spreecommerce.org/internals/preferences

    # preference :dark_chocolate, :boolean, default: true
    # preference :color, :string, default: 'Red'
    # preference :favorite_number, :integer
    # preference :supported_locales, :array, default: [:en]
    preference :enabled, :boolean, default: true
    preference :displayed_product_taxon_ids, :array, default: []
    preference :top_category_taxon_ids, :array, default: []
    preference :trending_category_taxon_ids, :array, default: []
    preference :featured_brand_taxon_ids, :array, default: []
    preference :featured_vendor_ids, :array, default: []

    def array_patch_value(value)
      return [] if value.blank?
      return value.split(',').compact_blank if instance_of?(String)

      value.compact_blank
    end

    def array_patch(key)
      array_patch_value(self[key])
    end
  end
end
