module SpreeCmCommissioner
  class VendorPhoto < Asset
    # 4x3
    def asset_styles
      {
        mini: '160x120>',
        small: '480x360>',
        medium: '960x720>'
      }
    end
  end
end
