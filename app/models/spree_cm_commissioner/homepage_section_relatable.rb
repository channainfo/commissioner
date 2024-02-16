module SpreeCmCommissioner
  class HomepageSectionRelatable < Base
    acts_as_list column: :position
    after_update :update_homepage_section

    belongs_to :homepage_section, counter_cache: true, optional: false, inverse_of: :homepage_section_relatables
    belongs_to :relatable, polymorphic: true, optional: false, inverse_of: :homepage_section_relatables

    scope :active, -> { where(active: true).order(:position) }

    private

    def update_homepage_section
      homepage_section.update(updated_at: Time.zone.now)
    end
  end
end
