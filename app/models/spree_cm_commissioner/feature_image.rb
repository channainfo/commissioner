module SpreeCmCommissioner
  class FeatureImage < SpreeCmCommissioner::Asset
    def asset_styles
      {
        mini: '187x67>',
        small: '375x135>',
        large: '960x480>'
      }
    end
  end
end
