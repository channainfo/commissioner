module SpreeCmCommissioner
  module HomepageSections
    class Find < ::Spree::BaseFinder
      ALLOWED_KINDS = SpreeCmCommissioner::HomepageSection.section_types.keys

      def execute
        by_section_type(scope)
      end

      private

      def by_section_type(scope)
        section_type = @params.dig(:filter, :section_type)

        return scope if section_type.blank?
        return scope if ALLOWED_KINDS.exclude?(section_type)

        scope.where(section_type: section_type)
      end
    end
  end
end
