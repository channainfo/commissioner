module SpreeCmCommissioner
  module Api
    module V2
      module ResourceSerializerConcernDecorator
        def self.prepended(base)
          def base.display_getter_methods(model_klazz)
            model_klazz.new.methods.find_all do |method_name|
              next unless method_name.to_s.start_with?('display_')
              next if method_name.to_s.end_with?('=')
              next if [Spree::Product, Spree::Variant].include?(model_klazz) && method_name == :display_amount

              # commissioner:
              # Skip 'display_vendor_' to not dynamic load 'display_vendor_' methods as attributes.
              #
              # In spree_multi_vendor, 'display_vendor_..' methods required :vendor args
              # while default attributes of spree_api does not provide that which cause error when serialize for PlatformApis & Webhook
              next if method_name.to_s.start_with?('display_vendor')

              method_name
            end
          end
        end
      end
    end
  end
end

unless Spree::Api::V2::ResourceSerializerConcern.included_modules.include?(SpreeCmCommissioner::Api::V2::ResourceSerializerConcernDecorator)
  Spree::Api::V2::ResourceSerializerConcern.prepend(SpreeCmCommissioner::Api::V2::ResourceSerializerConcernDecorator)
end
