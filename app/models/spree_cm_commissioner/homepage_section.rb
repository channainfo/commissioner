module SpreeCmCommissioner
  class HomepageSection < Base
    acts_as_list column: :position

    attribute :title
    attribute :description
    attribute :active
    attribute :position

    has_many :homepage_section_relatables, -> { active }, inverse_of: :homepage_section, dependent: :destroy

    scope :active, -> { where(active: true).order(:position) }
  end
end
