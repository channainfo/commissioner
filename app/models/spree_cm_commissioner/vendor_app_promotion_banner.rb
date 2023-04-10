module SpreeCmCommissioner
  class VendorAppPromotionBanner < Asset
    def asset_styles
      {
        mini: '100x50>',
        small: '400x100>',
        large: '800x200>',
        extra_large: '1200x300>'
      }
    end
  end
end
