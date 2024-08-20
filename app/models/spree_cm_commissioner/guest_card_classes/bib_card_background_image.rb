module SpreeCmCommissioner
  module GuestCardClasses
    class BibCardBackgroundImage < SpreeCmCommissioner::Asset
      def asset_styles
        {
          mini: '400x600>',
          small: '800x1200>'
        }
      end
    end
  end
end
