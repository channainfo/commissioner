module SpreeCmCommissioner
  class HomepageSection < Base
    include SpreeCmCommissioner::HomepageSectionBitwise

    acts_as_list column: :position

    attribute :segment, :integer, default: 0

    has_many :homepage_section_relatables, -> { active }, inverse_of: :homepage_section, dependent: :destroy

    scope :active, lambda {
      where(active: true)
        .joins(:homepage_section_relatables)
        .distinct
        .order(:position)
    }

    scope :filter_by_segment, -> (segment) { where('segment & ? > 0', BIT_SEGMENT[segment.to_sym]) }
  end
end
