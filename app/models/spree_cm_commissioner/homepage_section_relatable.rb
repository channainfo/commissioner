module SpreeCmCommissioner
  class HomepageSectionRelatable < Base
    acts_as_list column: :position
    after_update :update_homepage_section

    belongs_to :homepage_section, counter_cache: true, optional: false, inverse_of: :homepage_section_relatables
    belongs_to :relatable, polymorphic: true, optional: false, inverse_of: :homepage_section_relatables

    scope :active, lambda {
      where('available_on IS NULL OR available_on <= ?', Time.zone.now)
        .where('discontinue_on IS NULL OR discontinue_on >= ?', Time.zone.now)
        .order(:position)
    }

    def active?
      current_time = Time.zone.now
      (available_on.nil? || available_on <= current_time) &&
        (discontinue_on.nil? || discontinue_on >= current_time)
    end

    private

    def update_homepage_section
      homepage_section.update(updated_at: Time.zone.now)
    end
  end
end
