module SpreeCmCommissioner
  module ReviewDecorator
    def self.prepended(base)
      base.has_many :images, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::ReviewImage'
    end
  end
end

Spree::Review.prepend(SpreeCmCommissioner::ReviewDecorator) unless Spree::Review.included_modules.include?(SpreeCmCommissioner::ReviewDecorator)
