module SpreeCmCommissioner
  class HomepageBanner < Base
    acts_as_paranoid
    acts_as_list column: :priority

    validates_associated :app_image, :web_image

    has_one :app_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::HomepageBannerAppImage'
    has_one :web_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::HomepageBannerWebImage'

    scope :active, -> { where(active: true) }

    def toggle_status
      self.active = !active?

      save!
    end
  end
end
