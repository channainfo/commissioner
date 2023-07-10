module SpreeCmCommissioner
  class HomepageBackgroundWebImage < Asset
    def asset_styles
      {
        mini: '180x50>',
        small: '360x100>',
        medium: '720x200>',
        large: '1440x400>'
      }
    end
  end
end
