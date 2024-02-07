# This will be executed when run:
# bundle exec rake db:seed
#
module SpreeCmCommissioner
  module Seeds
    module RolesDecorator
      # override
      def call
        super

        Spree::Role.where(name: 'early_adopter').first_or_create!
      end
    end
  end
end

unless Spree::Seeds::Roles.included_modules.include?(SpreeCmCommissioner::Seeds::RolesDecorator)
  Spree::Seeds::Roles.prepend(SpreeCmCommissioner::Seeds::RolesDecorator)
end
