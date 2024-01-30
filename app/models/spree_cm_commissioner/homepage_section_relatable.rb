module SpreeCmCommissioner
  class HomepageSectionRelatable < Base
    acts_as_list column: :position
    after_update :update_homepage_section

    belongs_to :homepage_section, optional: false, inverse_of: :homepage_section_relatables, dependent: :destroy
    belongs_to :relatable, polymorphic: true, optional: false, inverse_of: :homepage_section_relatables, dependent: :destroy

    scope :active, -> { where(active: true).order(:position) }

    private

    def update_homepage_section
      homepage_section.update(updated_at: Time.zone.now)
    end
  end
end
