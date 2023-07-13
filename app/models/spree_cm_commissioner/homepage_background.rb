module SpreeCmCommissioner
  class HomepageBackground < Base
    acts_as_paranoid
    acts_as_list column: :priority

    validates_associated :app_image, :web_image

    has_one :app_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::HomepageBackgroundAppImage'
    has_one :web_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::HomepageBackgroundWebImage'

    scope :active, -> { where(active: true) }

    def toggle_status!
      self.active = !active?

      save!
    end
  end
end
