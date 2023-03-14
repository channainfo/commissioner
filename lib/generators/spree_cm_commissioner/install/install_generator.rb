module SpreeCmCommissioner
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :migrate, type: :boolean, default: true
      source_root File.expand_path('../../../../spree/templates', __dir__)

      def add_migrations
        gems = %i[
          spree_multi_vendor
          spree_cm_commissioner
        ]

        gems.each do |gem|
          run "bundle exec rake railties:install:migrations FROM=#{gem}"
        end
      end

      def run_migrations
        run_migrations = options[:migrate] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]'))
        if run_migrations
          run 'bundle exec rails db:migrate'
        else
          Rails.logger.debug 'Skipping rails db:migrate, don\'t forget to run it!'
        end
      end

      def install_admin
        return unless Spree::Core::Engine.backend_available?

        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', "\n *= require spree_cm_commissioner/backend",
                         after: %r{ *= require spree/backend}, verbose: true

        inject_into_file 'vendor/assets/javascripts/spree/backend/all.js', "\n//= require spree_cm_commissioner/backend",
                         after: %r{//= require spree/backend}, verbose: true
      end
    end
  end
end
