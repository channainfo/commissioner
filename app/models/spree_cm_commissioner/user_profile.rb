module SpreeCmCommissioner
  class UserProfile < Asset
    protected

    def asset_styles
      {
        thumb: '60x60>',
        small: '180x180>'
      }
    end
  end
end
