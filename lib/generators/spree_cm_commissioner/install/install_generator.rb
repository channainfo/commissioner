module SpreeCmCommissioner
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :migrate, type: :boolean, default: true
      source_root File.expand_path('../../../../spree/templates', __dir__)
      source_root File.expand_path('templates', __dir__)

      # it copy nationalities.yml to config/data before running the migration
      def copy_nationalities_data
        template 'config/data/nationalities.yml'
      end

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

        # For NPM support
        template 'app/javascript/spree_dashboard/spree_cm_commissioner/utilities.js'
        inject_into_file 'app/javascript/spree_dashboard/spree-dashboard.js', "\nimport \"./spree_cm_commissioner/utilities.js\"",
                         after: %r{import "@spree/dashboard"}, verbose: true
      end

      def install_telegram_web_bot
        template 'vendor/assets/javascript/spree_cm_commissioner/telegram/all.js'
        template 'vendor/assets/stylesheets/spree_cm_commissioner/telegram/all.css'
      end
    end
  end
end
