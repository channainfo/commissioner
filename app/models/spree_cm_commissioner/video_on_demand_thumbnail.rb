module SpreeCmCommissioner
  class VideoOnDemandThumbnail < SpreeCmCommissioner::Asset
    def asset_styles
      {
        mini: '160x90>',
        small: '240x135>',
        large: '360x202>'
      }
    end
  end
end
