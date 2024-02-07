module SpreeCmCommissioner
  class HomepageSection < Base
    acts_as_list column: :position

    enum section_type: {
      general: 0,
      ticket: 1
    }

    attribute :title
    attribute :description
    attribute :active
    attribute :position

    has_many :homepage_section_relatables, -> { active }, inverse_of: :homepage_section, dependent: :destroy

    scope :active, -> { where(active: true).order(:position) }
  end
end
