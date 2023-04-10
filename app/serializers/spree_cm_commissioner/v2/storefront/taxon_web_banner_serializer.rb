module SpreeCmCommissioner
  module V2
    module Storefront
      class TaxonWebBannerSerializer < BaseSerializer
        set_type :taxon_web_banner

        attributes :viewable_type, :viewable_id, :mobile_styles
      end
    end
  end
end
