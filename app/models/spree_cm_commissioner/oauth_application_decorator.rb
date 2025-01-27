module SpreeCmCommissioner
  module OauthApplicationDecorator
    def self.prepended(base)
      base.belongs_to :tenant, class_name: 'SpreeCmCommissioner::Tenant'
    end
  end
end

unless Spree::OauthApplication.included_modules.include?(SpreeCmCommissioner::OauthApplicationDecorator)
  Spree::OauthApplication.prepend(SpreeCmCommissioner::OauthApplicationDecorator)
end
