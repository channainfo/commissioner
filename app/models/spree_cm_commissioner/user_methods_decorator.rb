module SpreeCmCommissioner
  module UserMethodsDecorator
    def self.prepend(base)
      base.has_many :wished_items, through: :wishlists
    end
  end
end

unless Spree::UserMethods.included_modules.include?(SpreeCmCommissioner::UserMethodsDecorator)
  Spree::UserMethods.prepend(SpreeCmCommissioner::UserMethodsDecorator)
end
