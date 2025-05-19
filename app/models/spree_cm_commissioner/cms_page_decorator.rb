module SpreeCmCommissioner
  module CmsPageDecorator
    def self.prepended(base)
      base.multi_tenant :tenant, class_name: 'SpreeCmCommissioner::Tenant'
    end
  end
end

Spree::CmsPage.prepend(SpreeCmCommissioner::CmsPageDecorator) unless Spree::CmsPage.included_modules.include?(SpreeCmCommissioner::CmsPageDecorator)
