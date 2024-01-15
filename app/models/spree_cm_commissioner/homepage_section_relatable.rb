module SpreeCmCommissioner
  class HomepageSectionRelatable < Base
    acts_as_list column: :position

    belongs_to :homepage_section, optional: false, inverse_of: :homepage_section_relatables, touch: true, dependent: :destroy
    belongs_to :relatable, polymorphic: true, optional: false, inverse_of: :homepage_section_relatables, touch: true, dependent: :destroy

    scope :active, -> { where(active: true).order(:position) }
  end
end
