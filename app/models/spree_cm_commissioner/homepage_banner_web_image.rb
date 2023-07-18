module SpreeCmCommissioner
  class HomepageBannerWebImage < Asset
    # 2x1
    def asset_styles
      {
        mini: '240x120>',
        small: '480x240>',
        large: '960x480>>'
      }
    end
  end
end
