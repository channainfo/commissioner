module SpreeCmCommissioner
  class VehiclePhoto < Asset

    # 16x9
    def asset_styles
      {
        mini: '160x90>',
        small: '480x270>',
        medium: '960x540>'
      }
    end
  end
end